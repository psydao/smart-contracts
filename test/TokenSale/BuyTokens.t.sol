// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract BuyTokensTest is TestSetup {

    function setUp() public {
        setUpTests();
        vm.prank(alice);
        usdc.mint(address(alice), 10e18);
    }

    function test_FailsIfAmountIsMoreThanSupply() public {
        psyToken.mint(address(tokenSale), 1e18);
        vm.prank(owner);
        tokenSale.setSupply();

        vm.startPrank(alice);
        usdc.approve(address(tokenSale), 10e18);
        vm.expectRevert("PsyToken: Not enough supply");
        tokenSale.buyTokens(9e18);
    }

    function test_FailsIfUserHasInsufficientUSDCBalance() public {
        psyToken.mint(address(tokenSale), 1000e18);
        vm.prank(owner);
        tokenSale.setSupply();

        vm.startPrank(alice);
        usdc.approve(address(tokenSale), 10e18);
        vm.expectRevert("USDC: User has insufficient balance");
        tokenSale.buyTokens(1000e18);
    }

    function test_BuyTokensWorksCorrectly() public {

        assertEq(usdc.balanceOf(address(alice)), 10e18);

        psyToken.mint(address(tokenSale), 10e18);
        assertEq(psyToken.balanceOf(address(tokenSale)), 10e18);

        assertEq(tokenSale.supply(), 0);
        vm.prank(owner);
        tokenSale.setSupply();
        assertEq(tokenSale.supply(), 10e18);

        assertEq(usdc.balanceOf(address(tokenSale)), 0);
        assertEq(psyToken.balanceOf(address(alice)), 0);

        vm.startPrank(alice);
        usdc.approve(address(tokenSale), 10e18);
        tokenSale.buyTokens(9e18);

        assertEq(usdc.balanceOf(address(tokenSale)), 9e17);
        assertEq(tokenSale.userBalances(address(alice)), 9e18);
        assertEq(psyToken.balanceOf(address(alice)), 0);
    }
}
