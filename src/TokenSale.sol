// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


contract TokenSale {

    uint256 public constant PRICE = 1e17;
    uint256 public totalSupply;

    bool public saleClosed;

    mapping(address => uint256) public userBalances;

    IERC20 public psyToken;
    IERC20 public usdc;

    constructor(address _psyToken, address _usdc) {
        psyToken = IERC20(_psyToken);
        usdc = IERC20(_usdc);
        totalSupply = psyToken.totalSupply() * 10 / 100;
    }

    function buyTokens(uint256 _amountOfPsyTokens) external {
        uint256 totalCost = _amountOfPsyTokens * PRICE;
        require(usdc.transferFrom(msg.sender, address(this), totalCost), "USDC: Transfer Failed");
        require(psyToken.transfer(msg.sender, _amountOfPsyTokens), "PsyToken: Transfer Failed");
    }

    function withdrawTokens() external {
        require(userBalances[msg.sender] > 0, "Insufficient funds");
        require(saleClosed, "Tokens locked");

        uint256 amount = userBalances[msg.sender];
        userBalances[msg.sender] = 0;

        require(psyToken.transfer(msg.sender, amount), "Transfer failed");                                                         
    }





    
}
