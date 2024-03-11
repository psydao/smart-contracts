// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";
import "../../src/PsyNFT.sol";


contract MintBatchInFibonacciTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_BatchMintFailsWhenNonOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        psyNFT.batchMintInFibonacci();
    }

    function test_BatchMintWorks() public {
        assertEq(psyNFT.secondLastFibonacci(), 0);
        assertEq(psyNFT.previousFibonacci(), 0);
        assertEq(psyNFT.tokenId(), 0);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 0);
       
        vm.startPrank(owner);
        
        psyNFT.initialMint();
        psyNFT.batchMintInFibonacci();
        psyNFT.batchMintInFibonacci();
        psyNFT.batchMintInFibonacci();
        psyNFT.batchMintInFibonacci();
        psyNFT.batchMintInFibonacci();

        assertEq(psyNFT.secondLastFibonacci(), 13);
        assertEq(psyNFT.previousFibonacci(), 21);
        assertEq(psyNFT.tokenId(), 55);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 55);

        vm.stopPrank();
    }

}
