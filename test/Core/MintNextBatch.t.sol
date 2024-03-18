// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract MintNextBatchTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_BatchMintFailsWhenNotContractOwner() public {
        vm.prank(owner);
        psyNFT.initialMint();
        
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        core.mintNextBatch();
    }

    function test_BatchMintWorks() public {
        assertEq(psyNFT.previousFibonacci(), 0);
        assertEq(psyNFT.tokenId(), 0);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 0);
       
        vm.startPrank(owner);
        psyNFT.initialMint();

        core.mintNextBatch();
        core.mintNextBatch();
        core.mintNextBatch();
        core.mintNextBatch();
        core.mintNextBatch();

        assertEq(psyNFT.previousFibonacci(), 34);
        assertEq(psyNFT.tokenId(), 55);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 55);

        vm.stopPrank();
    }
}
