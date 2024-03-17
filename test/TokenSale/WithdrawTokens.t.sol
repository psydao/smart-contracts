// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract WithdrawTokensTest is TestSetup {

    function setUp() public {
        setUpTests();
        buyTokensForUsers();
    }

    function test_FailsIfNotInWithdrawableStatus() public {
        vm.prank(alice);
        vm.expectRevert("PsyToken: Tokens Locked");
        tokenSale.withdrawTokens();
    }

    function test_FailsIfUserHasNoPsyTokens() public {
        vm.startPrank(owner);
        tokenSale.pauseSale();
        tokenSale.unlockToken();
        vm.stopPrank();

        vm.prank(robyn);
        vm.expectRevert("PsyToken: Insufficient funds");
        tokenSale.withdrawTokens();
    }

    function test_WithdrawTokensWorks() public {
        vm.startPrank(owner);
        tokenSale.pauseSale();
        tokenSale.unlockToken();
        vm.stopPrank();

        assertEq(psyToken.balanceOf(address(alice)), 0);
        vm.prank(alice);
        tokenSale.withdrawTokens();
        assertEq(psyToken.balanceOf(address(alice)), 10);
        assertEq(psyToken.balanceOf(address(tokenSale)), 90);
        assertEq(tokenSale.userBalances(address(alice)), 0);

        assertEq(psyToken.balanceOf(address(owner)), 0);
        vm.prank(owner);
        tokenSale.withdrawTokens();
        assertEq(psyToken.balanceOf(address(owner)), 50);
        assertEq(psyToken.balanceOf(address(tokenSale)), 40);
        assertEq(tokenSale.userBalances(address(owner)), 0);

        assertEq(psyToken.balanceOf(address(bob)), 0);
        vm.prank(bob);
        tokenSale.withdrawTokens();
        assertEq(psyToken.balanceOf(address(bob)), 15);
        assertEq(psyToken.balanceOf(address(tokenSale)), 25);
        assertEq(tokenSale.userBalances(address(bob)), 0);
    }

    function buyTokensForUsers() public {
        psyToken.mint(address(tokenSale), 100);
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
        vm.deal(owner, 100 ether);

        vm.prank(owner);
        tokenSale.setSupply();

        vm.startPrank(alice);
        tokenSale.buyTokens{value: 1 ether}(10);
        vm.stopPrank();

        vm.startPrank(owner);
        tokenSale.buyTokens{value: 5 ether}(50);
        vm.stopPrank();

        vm.startPrank(bob);
        tokenSale.buyTokens{value: 1.5 ether}(15);
        vm.stopPrank();

        assertEq(address(tokenSale).balance, 7.5 ether);
        assertEq(tokenSale.userBalances(address(alice)), 10);
        assertEq(tokenSale.userBalances(address(owner)), 50);
        assertEq(tokenSale.userBalances(address(bob)), 15);
        assertEq(psyToken.balanceOf(address(tokenSale)), 100);
    }
}
