// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract MintNextBatchTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_BatchMintFailsWhenNotContractOwner() public {
        vm.prank(owner);
        core.mintInitialBatch();
        
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        core.mintNextBatch();
    }

    function test_BatchMintWorks() public {
        assertEq(psyNFT.previousFibonacci(), 2);
        assertEq(psyNFT.tokenId(), 0);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 0);
       
        vm.startPrank(owner);
        core.mintInitialBatch();

        core.mintNextBatch();
        core.mintNextBatch();
        core.mintNextBatch();
        core.mintNextBatch();
        core.mintNextBatch();

        assertEq(psyNFT.previousFibonacci(), 21);
        assertEq(psyNFT.tokenId(), 34);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 34);

        vm.stopPrank();
    }
}
