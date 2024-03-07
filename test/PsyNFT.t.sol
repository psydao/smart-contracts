// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/PsyNFT.sol";


contract PsyNFTTest is Test {

    error OwnableUnauthorizedAccount(address account);

    PsyNFT public psyNFT;

    address owner = vm.addr(1);
    address alice = vm.addr(2);
    address bob = vm.addr(3);

    function setUp() public {
        vm.startPrank(owner);
        psyNFT = new PsyNFT();
        vm.stopPrank();
    }

    function test_MintFailsWhenNonOwner() public {
        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        psyNFT.initialMint();

        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        psyNFT.mintBatchInFibonacci();

        vm.stopPrank();
    }

    function test_InitialMintFailsIfAlreadyCalled() public {
        vm.startPrank(owner);

        psyNFT.initialMint();

        vm.expectRevert("Initial mint completed");
        psyNFT.initialMint();
    }

    function test_PsyNFTCanMintCorrectly() public {
        assertEq(psyNFT.secondLastFibonacci(), 0);
        assertEq(psyNFT.previousFibonacci(), 0);
        assertEq(psyNFT.tokenId(), 0);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 0);

        vm.startPrank(owner);

        psyNFT.initialMint();

        assertEq(psyNFT.secondLastFibonacci(), 1);
        assertEq(psyNFT.previousFibonacci(), 2);
        assertEq(psyNFT.tokenId(), 5);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 5);

        psyNFT.mintBatchInFibonacci();
        psyNFT.mintBatchInFibonacci();
        psyNFT.mintBatchInFibonacci();
        psyNFT.mintBatchInFibonacci();
        psyNFT.mintBatchInFibonacci();

        assertEq(psyNFT.secondLastFibonacci(), 13);
        assertEq(psyNFT.previousFibonacci(), 21);
        assertEq(psyNFT.tokenId(), 55);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 55);

        vm.stopPrank();
    }
   
}
