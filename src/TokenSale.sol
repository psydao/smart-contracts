// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";

contract TokenSale is Ownable2Step, ReentrancyGuard {
    using SafeERC20 for IERC20;

    enum SaleStatus {
        OPEN,
        PAUSED,
        WITHDRAWABLE
    }

    uint256 public tokenPriceInUsdc;
    uint256 public supply;

    SaleStatus public saleStatus;

    mapping(address => uint256) public userBalances;

    IERC20 public immutable psyToken;
    IERC20 public immutable usdc;

    constructor(address _psyToken, address _usdc, uint256 _tokenPrice) Ownable(msg.sender) {
        require(_psyToken != address(0), "Cannot be address 0");
        require(_usdc != address(0), "Cannot be address 0");

        psyToken = IERC20(_psyToken);
        usdc = IERC20(_usdc);
        tokenPriceInUsdc = _tokenPrice;
    }

    /**
     * @notice Allows users to buy a specified amount of PsyTokens.
     * @param _amountOfPsyTokens The amount of PsyTokens to buy.
     */
    function buyTokens(uint256 _amountOfPsyTokens) external nonReentrant {
        require(saleStatus == SaleStatus.OPEN, "PsyToken: Sale Paused");
        require(_hasSufficientSupplyForPurchase(_amountOfPsyTokens), "PsyToken: Not enough supply");

        uint256 usdcAmount = (_amountOfPsyTokens * tokenPriceInUsdc) / 10e18;
        require(usdc.balanceOf(msg.sender) >= usdcAmount, "USDC: User has insufficient balance");

        userBalances[msg.sender] += _amountOfPsyTokens;
        supply -= _amountOfPsyTokens;

        if (supply == 0) {
            saleStatus = SaleStatus.PAUSED;
        }

        usdc.safeTransferFrom(msg.sender, address(this), usdcAmount);
    }
    /**
     * @notice Allows a user to withdraw their tokens.
     * @dev The user must have a positive balance of tokens and the sale status must be set to WITHDRAWABLE.
     */
    function withdrawTokens() external nonReentrant {
        require(saleStatus == SaleStatus.WITHDRAWABLE, "PsyToken: Tokens Locked");
        require(userBalances[msg.sender] > 0, "PsyToken: Insufficient funds");

        uint256 amount = userBalances[msg.sender];
        userBalances[msg.sender] = 0;

        psyToken.safeTransfer(msg.sender, amount);
    }

    function pauseSale() external onlyOwner {
        require(saleStatus == SaleStatus.OPEN, "PsyToken: Token Not Open");
        saleStatus = SaleStatus.PAUSED;
    }

    function resumeSale() external onlyOwner {
        require(saleStatus == SaleStatus.PAUSED, "PsyToken: Token Not Paused");
        require(supply > 0, "PsyToken: Supply Finished");
        saleStatus = SaleStatus.OPEN;
    }

    function unlockToken() external onlyOwner {
        require(saleStatus == SaleStatus.PAUSED, "PsyToken: Token Not Paused");
        saleStatus = SaleStatus.WITHDRAWABLE;
    }

    function setSupply() external onlyOwner {
        supply = psyToken.balanceOf(address(this));
    }

    function setTokenPrice(uint256 _newPrice) external onlyOwner {
        require(_newPrice != tokenPriceInUsdc, "PsyToken: New Token Price Same As Current");
        tokenPriceInUsdc = _newPrice;
    }

    function _hasSufficientSupplyForPurchase(uint256 _amount) internal view returns (bool) {
        require(_amount > 0, "Amount Must Be Bigger Than 0");
        return (supply >= _amount);
    }
}
