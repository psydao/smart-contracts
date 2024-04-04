// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract DepositPsyTokensForSaleTest is TestSetup {

    uint256 sepoliaFork;
    uint256 mainnetFork;
    string SEPOLIA_RPC_URL = vm.envString("SEPOLIA_RPC_URL");
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    function setUp() public {
        setUpFork();
        setUpTests();
    }

    function test_FailsIfNotOwner() public {
        psyToken.mint(address(owner), 10 ether);
        vm.prank(owner);
        psyToken.approve(address(tokenSale), 10 ether);

        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        tokenSale.depositPsyTokensForSale(100);
    }

    function test_DepositTokensWorks() public {

        uint256 MINT_AMOUNT = 10 ether;

        assertEq(psyToken.balanceOf(address(owner)), 0);
        assertEq(tokenSale.totalTokensForSale(), 0);
        
        psyToken.mint(address(owner), MINT_AMOUNT);
        assertEq(psyToken.balanceOf(address(owner)), 10 ether);

        vm.startPrank(owner);
        psyToken.approve(address(tokenSale), 10 ether);
        tokenSale.depositPsyTokensForSale(100);
        vm.stopPrank();

        assertEq(psyToken.balanceOf(address(owner)), MINT_AMOUNT - 100);
        assertEq(tokenSale.totalTokensForSale(), 100);

        vm.startPrank(owner);
        tokenSale.depositPsyTokensForSale(50);
        vm.stopPrank();

        assertEq(psyToken.balanceOf(address(owner)), MINT_AMOUNT - 150);
        assertEq(tokenSale.totalTokensForSale(), 150);

    }

    function setUpFork() public {
        sepoliaFork = vm.createFork(SEPOLIA_RPC_URL);
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
    }
}
