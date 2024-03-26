// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract BatchMintInFibonacciTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_BatchMintFailsWhenNotCoreContract() public {
        vm.prank(owner);
        core.mintInitialBatch();

        vm.expectRevert("PsyNFT: Caller Not Core Contract");
        psyNFT.batchMintInFibonacci();
    }

    function test_BatchMintFailsIfInitialMintNotComplete() public {
        vm.prank(address(core));
        vm.expectRevert("PsyNFT: Initial Mint Not Completed");
        psyNFT.batchMintInFibonacci();
    }

    function test_BatchMintWorks() public {
        assertEq(psyNFT.previousFibonacci(), 3);
        assertEq(psyNFT.tokenId(), 0);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 0);
       
        vm.prank(owner);
        core.mintInitialBatch();

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
