// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract WithdrawTokensTest is TestSetup {

    uint256 sepoliaFork;
    uint256 mainnetFork;
    string SEPOLIA_RPC_URL = vm.envString("SEPOLIA_RPC_URL");
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    function setUp() public {
        setUpFork();
        setUpTests();
        buyTokensForUsers();
    }

    function test_FailsIfNotInWithdrawableStatus() public {
        vm.prank(alice);
        vm.expectRevert("TokenSale: Tokens Locked");
        tokenSale.withdrawTokens();
    }

    function test_FailsIfUserHasNoPsyTokens() public {
        vm.startPrank(owner);
        tokenSale.pauseSale();
        tokenSale.unlockToken();
        vm.stopPrank();

        vm.prank(robyn);
        vm.expectRevert("TokenSale: Insufficient funds");
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

        assertEq(psyToken.balanceOf(address(owner)), 10 ether - 100);
        vm.prank(owner);
        tokenSale.withdrawTokens();
        assertEq(psyToken.balanceOf(address(owner)), 10 ether - 50);
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
        psyToken.mint(address(owner), 10 ether);
        vm.startPrank(owner);
        psyToken.approve(address(tokenSale), 10 ether);
        tokenSale.depositPsyTokensForSale(100);
        vm.stopPrank();
        
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
        vm.deal(owner, 100 ether);

        uint256 amountAliceMustPay = tokenSale.calculateEthAmountPerPsyToken() * 10;

        vm.startPrank(alice);
        tokenSale.buyTokens{value: amountAliceMustPay}(10);
        vm.stopPrank();

        uint256 amountOwnerMustPay = tokenSale.calculateEthAmountPerPsyToken() * 50;

        vm.startPrank(owner);
        tokenSale.buyTokens{value: amountOwnerMustPay}(50);
        vm.stopPrank();

        uint256 amountBobMustPay = tokenSale.calculateEthAmountPerPsyToken() * 15;

        vm.startPrank(bob);
        tokenSale.buyTokens{value: amountBobMustPay}(15);
        vm.stopPrank();

        assertEq(address(tokenSale).balance, amountAliceMustPay + amountOwnerMustPay + amountBobMustPay);
        assertEq(tokenSale.userBalances(address(alice)), 10);
        assertEq(tokenSale.userBalances(address(owner)), 50);
        assertEq(tokenSale.userBalances(address(bob)), 15);
        assertEq(psyToken.balanceOf(address(tokenSale)), 100);
    }

    function setUpFork() public {
        sepoliaFork = vm.createFork(SEPOLIA_RPC_URL);
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
    }
}
