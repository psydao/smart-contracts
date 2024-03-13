// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";

import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";

contract TokenSale is Ownable2Step {

    uint256 public constant tokenPriceInUsdc = 10e17;
    uint256 public supply;

    bool public saleClosed;

    mapping(address => uint256) public userBalances;

    IERC20 public psyToken;
    IERC20 public usdc;

    constructor(address _psyToken, address _usdc) Ownable(msg.sender) {
        psyToken = IERC20(_psyToken);
        usdc = IERC20(_usdc);
    }

    function buyTokens(uint256 _amountOfPsyTokens) external {
        require(supply >= _amountOfPsyTokens, "PsyToken: Not enough supply");
        uint256 usdcAmount = (_amountOfPsyTokens * tokenPriceInUsdc) / 10e18;
        require(usdc.balanceOf(msg.sender) >= usdcAmount, "USDC: User has insufficient balance");
        userBalances[msg.sender] += _amountOfPsyTokens;
        require(usdc.transferFrom(msg.sender, address(this), usdcAmount), "USDC: Transfer Failed");
    }

    function withdrawTokens() external {
        require(userBalances[msg.sender] > 0, "PsyToken: Insufficient funds");
        require(saleClosed, "Tokens locked");

        uint256 amount = userBalances[msg.sender];
        userBalances[msg.sender] = 0;

        require(psyToken.transfer(msg.sender, amount), "Transfer failed");                                                         
    }

    function setSupply() external onlyOwner {
        supply = psyToken.balanceOf(address(this));
    }
}
