// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract WithdrawFundsFromContractTest is TestSetup {
    uint256 mainnetFork;
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    function setUp() public {
        setUpFork();
        setUpTests();
        vm.deal(alice, 100 ether);
    }

    function test_FailsIfReceiverIsAddressZero() public {
        psyToken.mint(address(owner), 10 ether);
        vm.startPrank(owner);
        psyToken.approve(address(tokenSale), 10 ether);
        tokenSale.depositPsyTokensForSale(10);
        vm.stopPrank();

        uint256 amountAliceMustPay = tokenSale.calculateEthAmountPerPsyToken() * 9;

        vm.prank(alice);
        tokenSale.buyTokens{value: amountAliceMustPay}(9);

        vm.prank(owner);
        vm.expectRevert("TokenSale: Receiver Cannot Be Zero Address");
        tokenSale.withdrawFunds(address(0));
    }

    function test_FailsIfCallerIsnotContractOwner() public {
        psyToken.mint(address(owner), 10 ether);
        vm.startPrank(owner);
        psyToken.approve(address(tokenSale), 10 ether);
        tokenSale.depositPsyTokensForSale(10);
        vm.stopPrank();

        uint256 amountAliceMustPay = tokenSale.calculateEthAmountPerPsyToken() * 9;

        vm.prank(alice);
        tokenSale.buyTokens{value: amountAliceMustPay}(9);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        tokenSale.withdrawFunds(address(alice));
    }

    function test_WithdrawsEthToOwner() public {
        psyToken.mint(address(owner), 10 ether);
        vm.startPrank(owner);
        psyToken.approve(address(tokenSale), 10 ether);
        tokenSale.depositPsyTokensForSale(10);
        vm.stopPrank();

        uint256 amountAliceMustPay = tokenSale.calculateEthAmountPerPsyToken() * 9;

        vm.prank(alice);
        tokenSale.buyTokens{value: amountAliceMustPay}(9);
        
        assertEq(address(tokenSale).balance, amountAliceMustPay);
        uint256 ownerBalanceBeforeTransfer = address(owner).balance;

        vm.prank(owner);
        tokenSale.withdrawFunds(address(owner));

        assertEq(address(tokenSale).balance, 0);
        assertEq(address(owner).balance, ownerBalanceBeforeTransfer + amountAliceMustPay);
    }

    function setUpFork() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
    }
}
