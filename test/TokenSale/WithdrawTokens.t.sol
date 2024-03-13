// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract WithdrawTokensTest is TestSetup {

    function setUp() public {
        setUpTests();
        buyTokensForUsers();
    }

    function buyTokensForUsers() public {
        psyToken.mint(address(tokenSale), 100e18);
        usdc.mint(address(alice), 10e18);
        usdc.mint(address(owner), 10e18);
        usdc.mint(address(bob), 10e18);

        vm.prank(owner);
        tokenSale.setSupply();

        vm.startPrank(alice);
        usdc.approve(address(tokenSale), 10e18);
        tokenSale.buyTokens(10e18);
        vm.stopPrank();

        vm.startPrank(owner);
        usdc.approve(address(tokenSale), 50e18);
        tokenSale.buyTokens(50e18);
        vm.stopPrank();

        vm.startPrank(bob);
        usdc.approve(address(tokenSale), 20e18);
        tokenSale.buyTokens(15e18);
        vm.stopPrank();

        assertEq(usdc.balanceOf(address(tokenSale)), 75e17);
        assertEq(tokenSale.userBalances(address(alice)), 10e18);
        assertEq(tokenSale.userBalances(address(owner)), 50e18);
        assertEq(tokenSale.userBalances(address(bob)), 15e18);
        assertEq(psyToken.balanceOf(address(tokenSale)), 100e18);
    }
}
