// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract MintBatchInFibonacciTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_BatchMintFailsWhenNotCoreContract() public {
        vm.startPrank(owner);
        psyNFT.initialMint();

        vm.expectRevert("Only callable by Core.sol");
        psyNFT.batchMintInFibonacci();
    }

    function test_BatchMintFailsIfInitialMintNotComplete() public {
        vm.prank(address(core));
        vm.expectRevert("Initial mint not completed");
        psyNFT.batchMintInFibonacci();
    }

    function test_BatchMintWorks() public {
        assertEq(psyNFT.previousFibonacci(), 0);
        assertEq(psyNFT.tokenId(), 0);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 0);
       
        vm.prank(owner);
        psyNFT.initialMint();

        vm.startPrank(address(core));
        psyNFT.batchMintInFibonacci();
        psyNFT.batchMintInFibonacci();
        psyNFT.batchMintInFibonacci();
        psyNFT.batchMintInFibonacci();
        psyNFT.batchMintInFibonacci();

        assertEq(psyNFT.previousFibonacci(), 34);
        assertEq(psyNFT.tokenId(), 55);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 55);

        vm.stopPrank();
    }

}
