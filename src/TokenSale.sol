// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/interfaces/feeds/AggregatorV3Interface.sol";

contract TokenSale is Ownable2Step, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public tokenPriceInDollar;
    uint256 public totalTokensForSale;
    uint256 constant ETH_AMOUNT_MULTIPLIER = 1e10;
    uint256 immutable CHAINLINK_STALE_DATA_PERIOD = 3 hours;

    bool public saleActive;
    bool public tokensLocked;

    mapping(address => uint256) public userBalances;

    IERC20 public immutable psyToken;
    AggregatorV3Interface public dataFeed;

    event TokensBought(address buyer, uint256 amount);
    event TokensWithdrawn(address withdrawer, uint256 amount);
    event SalePaused();
    event SaleResumed();
    event TokenUnlocked();

    constructor(address _psyToken, address _chainlinkPriceFeed, uint256 _tokenPrice) Ownable(msg.sender) {
        require(_psyToken != address(0), "TokenSale: Cannot Be Zero Address");
        require(_chainlinkPriceFeed != address(0), "TokenSale: Cannot Be Zero Address");

        //Mainnet USD/ETH price feed address
        dataFeed = AggregatorV3Interface(_chainlinkPriceFeed);

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
        require(saleActive, "TokenSale: Sale Paused");
        require(_amountOfPsyTokens > 0, "TokenSale: Amount Must Be Bigger Than 0");
        require(_hasSufficientSupplyForPurchase(_amountOfPsyTokens), "TokenSale: Not enough supply");

        uint256 ethPricePerToken = calculateEthAmountPerPsyToken();
        uint256 ethAmount = _amountOfPsyTokens * ethPricePerToken;
        require(msg.value == ethAmount, "TokenSale: Incorrect Amount Sent In");

        userBalances[msg.sender] += _amountOfPsyTokens;
        totalTokensForSale -= _amountOfPsyTokens;

        if (totalTokensForSale == 0) {
            saleActive = false;
        }

        emit TokensBought(msg.sender, _amountOfPsyTokens);
    }

    /**
     * @notice Allows a user to withdraw their PSY tokens.
     * @dev The user must have a positive balance of tokens and the sale status must be set to WITHDRAWABLE.
     */
    function withdrawTokens() external nonReentrant {
        require(!tokensLocked, "TokenSale: Tokens Locked");
        require(userBalances[msg.sender] > 0, "TokenSale: Insufficient funds");

        uint256 amount = userBalances[msg.sender];
        userBalances[msg.sender] = 0;

        psyToken.safeTransfer(msg.sender, amount);

        emit TokensWithdrawn(msg.sender, amount);
    }

    /**
     * @notice Pauses the token sale.
     * @dev Only the contract owner can call this function.
     * @dev The sale status must be set to OPEN in order to pause it.
     */
    function pauseSale() external onlyOwner {
        require(saleActive, "TokenSale: Token Already Paused");
        saleActive = false;

        emit SalePaused();
    }

    /**
     * @notice Resumes the token sale.
     * @dev Only the contract owner can call this function.
     * @dev The sale status must be set to PAUSED and the totalTokensForSale must be greater than 0 in order to resume the sale.
     */
    function resumeSale() external onlyOwner {
        require(!saleActive, "TokenSale: Token Not Paused");
        require(totalTokensForSale > 0, "TokenSale: Supply Finished");
        saleActive = true;

        emit SalePaused();
    }

    /**
     * @notice Unlocks the token for withdrawal.
     * @dev Only the contract owner can call this function.
     */
    function unlockToken() external onlyOwner {
        require(tokensLocked, "TokenSale: Tokens Already Unlocked");
        tokensLocked = false;

        emit TokenUnlocked();
    }

    /**
     * @notice Deposits a specified amount of PsyTokens into the contract for sale.
     * @param _amountToDeposit The amount of PsyTokens to deposit for sale.
     * @dev The sale status must be set to PAUSED in order to unlock the token.
     */
    function depositPsyTokensForSale(uint256 _amountToDeposit) external onlyOwner {
        totalTokensForSale += _amountToDeposit;
        psyToken.safeTransferFrom(msg.sender, address(this), _amountToDeposit);
    }

    /**
     * @notice Sets the token price in USDC.
     * @dev Only the contract owner can call this function.
     * @param _newPrice The new token price in USDC.
     * @dev The new price must be different from the current token price.
     */
    function setTokenPrice(uint256 _newPrice) external onlyOwner {
        require(_newPrice != tokenPriceInDollar, "TokenSale: New Token Price Same As Current");
        tokenPriceInDollar = _newPrice;
    }

    /**
     * @notice Updates the Chainlink price feed address used for calculating the amount of Ether required to purchase one PsyToken.
     * @param _newPriceFeed The new address of the Chainlink price feed.
     * @notice This function updates the dataFeed variable with the new Chainlink price feed address.
     */
    function updateChainlinkPriceFeed(address _newPriceFeed) external onlyOwner {
        require(_newPriceFeed != address(0), "TokenSale: Cannot Be Address 0");
        dataFeed = AggregatorV3Interface(_newPriceFeed);
    }

    /**
     * @notice Calculates the amount of Ether required to purchase one PsyToken.
     * @dev The token price in USDC must be greater than 0.
     * @return The amount of Ether required to purchase one PsyToken, multiplied by ETH_AMOUNT_MULTIPLIER.
     */
    function calculateEthAmountPerPsyToken() public returns (uint256) {
        require(tokenPriceInDollar != 0, "TokenSale: Token Is Free");

        uint256 dollarPricePerEth = _getDollarAmountPerEth();
        uint256 ethAmount = tokenPriceInDollar / dollarPricePerEth;

        return ethAmount * ETH_AMOUNT_MULTIPLIER;
    }

    /**
     * @notice Withdraws the contract's balance and sends it to the specified receiver address.
     * @param _receiver: The address to which the contract's balance will be sent.
     * @dev Only the contract owner can call this function.
     * @dev If the transfer fails, an error message is thrown.
     * @notice This function should be used with caution as it transfers the entire balance of the contract.
     */
    function withdrawFunds(address _receiver) external onlyOwner {
        require(_receiver != address(0), "TokenSale: Receiver Cannot Be Zero Address");
        (bool sent,) = _receiver.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    /**
     * @notice Checks if the contract has sufficient supply for a purchase.
     * @param _amount The amount of tokens to be purchased.
     * @return A boolean indicating whether the contract has sufficient supply for the purchase.
     */
    function _hasSufficientSupplyForPurchase(uint256 _amount) internal view returns (bool) {
        return (totalTokensForSale >= _amount);
    }

    /**
     * @notice Retrieves the latest dollar amount per Ether from the Chainlink price feed.
     * @dev This function calls the latestRoundData() function of the dataFeed contract to get the latest round data.
     * @return The dollar amount per Ether as an unsigned integer.
     */
    function _getDollarAmountPerEth() internal returns (uint256) {
        (uint80 roundID, int256 amount, , uint256 updatedAt, uint80 answeredInRound) = dataFeed.latestRoundData();

        require(answeredInRound >= roundID, "TokenSale: Stale price");
        require(updatedAt >= block.timestamp - CHAINLINK_STALE_DATA_PERIOD, "TokenSale: Incomplete Round");
        require(amount > 0, "TokenSale: Invalid price");
        
        return uint256(amount);
    }
}
