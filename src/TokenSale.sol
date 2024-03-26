// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/interfaces/feeds/AggregatorV3Interface.sol";
import "forge-std/console.sol";

contract TokenSale is Ownable2Step, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public tokenPriceInDollar;
    uint256 public supply;

    bool public saleActive;
    bool public tokensLocked;

    mapping(address => uint256) public userBalances;

    IERC20 public immutable psyToken;
    AggregatorV3Interface public dataFeed;

    constructor(address _psyToken, address _chainlinkPriceFeed, uint256 _tokenPrice) Ownable(msg.sender) {
        require(_psyToken != address(0), "TokenSale: Cannot Be Address 0");
        require(_chainlinkPriceFeed != address(0), "TokenSale: Cannot Be Address 0");

        //Mainnet USD/ETH price feed address
        dataFeed = AggregatorV3Interface(
            _chainlinkPriceFeed
        );

        psyToken = IERC20(_psyToken);
        tokenPriceInDollar = _tokenPrice;
        saleActive = true;
        tokensLocked = true;
    }

    /**
     * @notice Allows users to buy a specified amount of PsyTokens.
     * @param _amountOfPsyTokens The amount of PsyTokens to buy.
     */
    function buyTokens(uint256 _amountOfPsyTokens) external payable nonReentrant {
        require(saleActive, "PsyToken: Sale Paused");
        require(_amountOfPsyTokens > 0, "Amount Must Be Bigger Than 0");
        require(_hasSufficientSupplyForPurchase(_amountOfPsyTokens), "PsyToken: Not enough supply");

        uint256 ethPricePerToken = ethAmountPerPsyToken();
        uint256 ethAmount = _amountOfPsyTokens * ethPricePerToken;
        require(msg.value == ethAmount, "ETH: Incorrect Amount Sent In");

        userBalances[msg.sender] += _amountOfPsyTokens;
        supply -= _amountOfPsyTokens;

        if (supply == 0) {
            saleActive = false;
        }
    }

    /**
     * @notice Allows a user to withdraw their PSY tokens.
     * @dev The user must have a positive balance of tokens and the sale status must be set to WITHDRAWABLE.
     */
    function withdrawTokens() external nonReentrant {
        require(!tokensLocked, "PsyToken: Tokens Locked");
        require(userBalances[msg.sender] > 0, "PsyToken: Insufficient funds");

        uint256 amount = userBalances[msg.sender];
        userBalances[msg.sender] = 0;

        psyToken.safeTransfer(msg.sender, amount);
    }

    /**
     * @notice Pauses the token sale.
     * @dev Only the contract owner can call this function.
     * @dev The sale status must be set to OPEN in order to pause it.
     */
    function pauseSale() external onlyOwner {
        require(saleActive, "PsyToken: Token Already Paused");
        saleActive = false;
    }

    /**
     * @notice Resumes the token sale.
     * @dev Only the contract owner can call this function.
     * @dev The sale status must be set to PAUSED and the supply must be greater than 0 in order to resume the sale.
     */
    function resumeSale() external onlyOwner {
        require(!saleActive, "PsyToken: Token Not Paused");
        require(supply > 0, "PsyToken: Supply Finished");
        saleActive = true;
    }

    /**
     * @notice Unlocks the token for withdrawal.
     * @dev Only the contract owner can call this function.
     * @dev The sale status must be set to PAUSED in order to unlock the token.
     */
    function unlockToken() external onlyOwner {
        require(tokensLocked, "PsyToken: Tokens Already Unlocked");
        tokensLocked = false;
    }

    /**
     * @notice Sets the supply of PsyTokens.
     * @dev Only the contract owner can call this function.
     * @dev The supply is set to the balance of PsyTokens held by the contract.
     */
    function setSupply() external onlyOwner {
        supply = psyToken.balanceOf(address(this));
    }

    /**
     * @notice Sets the token price in USDC.
     * @dev Only the contract owner can call this function.
     * @param _newPrice The new token price in USDC.
     * @dev The new price must be different from the current token price.
     */
    function setTokenPrice(uint256 _newPrice) external onlyOwner {
        require(_newPrice != tokenPriceInDollar, "PsyToken: New Token Price Same As Current");
        tokenPriceInDollar = _newPrice;
    }

    function updateChainlinkPriceFeed(address _newPriceFeed) external onlyOwner {
        require(_newPriceFeed != address(0), "TokenSale: Cannot Be Address 0");
        dataFeed = AggregatorV3Interface(_newPriceFeed);
    }

    function ethAmountPerPsyToken() public returns (uint256) {
        uint256 dollarPricePerEth = _getDollarAmountPerEth();
        uint256 dollarRatio = dollarPricePerEth / tokenPriceInDollar;
        return 1 ether / dollarRatio;
    }

    /**
     * @notice Checks if the contract has sufficient supply for a purchase.
     * @param _amount The amount of tokens to be purchased.
     * @return A boolean indicating whether the contract has sufficient supply for the purchase.
     */
    function _hasSufficientSupplyForPurchase(uint256 _amount) internal view returns (bool) {
        return (supply >= _amount);
    }

    function _getDollarAmountPerEth() internal returns (uint256) {
        (
            /* uint80 roundID */,
            int amount,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return uint256(amount) * 10**10;
    }

    
}
