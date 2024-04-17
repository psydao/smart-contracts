// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract BuyTokensTest is TestSetup {
    uint256 sepoliaFork;
    uint256 mainnetFork;
    string SEPOLIA_RPC_URL = vm.envString("SEPOLIA_RPC_URL");
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    function setUp() public {
        setUpFork();
        setUpTests();
        vm.deal(alice, 100 ether);
    }

    function test_FailsIfNotEnoughSupply() public {
        psyToken.mint(address(owner), 1 ether);
        vm.startPrank(owner);
        psyToken.approve(address(tokenSale), 1 ether);
        tokenSale.depositPsyTokensForSale(1);

        uint256 amountAliceMustPay = tokenSale.calculateEthAmountPerPsyToken() * 9;

        vm.startPrank(alice);
        vm.expectRevert("TokenSale: Not enough supply");
        tokenSale.buyTokens{value: amountAliceMustPay}(9);
    }

    function test_FailsIfUserSendsIncorrectEthAmount() public {
        psyToken.mint(address(owner), 1 ether);
        vm.startPrank(owner);
        psyToken.approve(address(tokenSale), 1 ether);
        tokenSale.depositPsyTokensForSale(10);

        vm.startPrank(alice);
        vm.expectRevert("TokenSale: Incorrect Amount Sent In");
        tokenSale.buyTokens{value: 1.1 ether}(10);
    }

    function test_FailsIfSaleIsPaused() public {
        psyToken.mint(address(owner), 1 ether);
        vm.startPrank(owner);
        psyToken.approve(address(tokenSale), 1 ether);
        tokenSale.depositPsyTokensForSale(10);
        tokenSale.pauseSale();
        vm.stopPrank();

        uint256 amountAliceMustPay = tokenSale.calculateEthAmountPerPsyToken() * 10;

        vm.startPrank(alice);
        vm.expectRevert("TokenSale: Sale Paused");
        tokenSale.buyTokens{value: amountAliceMustPay}(10);
    }

    function test_FailsIfPurchasingZeroTokens() public {
        psyToken.mint(address(owner), 1 ether);
        vm.startPrank(owner);
        psyToken.approve(address(tokenSale), 1 ether);
        tokenSale.depositPsyTokensForSale(10);

        vm.startPrank(alice);
        vm.expectRevert("TokenSale: Amount Must Be Bigger Than 0");
        tokenSale.buyTokens{value: 0 ether}(0);
    }

    function test_BuyTokensWorksCorrectly() public {

        uint256 aliceEthBalanceBefore = address(alice).balance;
        assertEq(aliceEthBalanceBefore, 100 ether);

        psyToken.mint(address(owner), 1 ether);
        vm.startPrank(owner);
        psyToken.approve(address(tokenSale), 1 ether);
        tokenSale.depositPsyTokensForSale(10);
        assertEq(psyToken.balanceOf(address(tokenSale)), 10);
        assertEq(tokenSale.totalTokensForSale(), 10);

        assertEq(psyToken.balanceOf(address(alice)), 0);

        uint256 amountAliceMustPay = tokenSale.calculateEthAmountPerPsyToken() * 9;

        vm.startPrank(alice);
        tokenSale.buyTokens{value: amountAliceMustPay}(9);

        assertEq(tokenSale.totalTokensForSale(), 1);
        assertEq(address(tokenSale).balance, amountAliceMustPay);
        assertEq(tokenSale.userBalances(address(alice)), 9);
        assertEq(psyToken.balanceOf(address(alice)), 0);
        assertEq(address(alice).balance, aliceEthBalanceBefore - amountAliceMustPay);
    }

    function test_SalePausedIfSupplyRunsOut() public {
        psyToken.mint(address(owner), 9 ether);
        vm.startPrank(owner);
        psyToken.approve(address(tokenSale), 9 ether);
        tokenSale.depositPsyTokensForSale(9e18);

        assertEq(tokenSale.saleActive(), true);

        uint256 amountAliceMustPay = tokenSale.calculateEthAmountPerPsyToken() * 9;

        vm.startPrank(alice);
        tokenSale.buyTokens{value: amountAliceMustPay}(9e18);
        assertEq(tokenSale.saleActive(), false);
    }

    function setUpFork() public {
        sepoliaFork = vm.createFork(SEPOLIA_RPC_URL);
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
    }
}
