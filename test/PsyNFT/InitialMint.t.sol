// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";
contract InitialMintTest is TestSetup {

    function setUp() public {
       setUpTests();
    }

    function test_InitialMintFailsWhenNotCoreContract() public {
        vm.prank(alice);
        vm.expectRevert("PsyNFT: Caller Not Core Contract");
        psyNFT.initialMint();
    }

    function test_InitialMintFailsWhenAlreadyCalled() public {
         vm.startPrank(address(core));
        psyNFT.initialMint();
        vm.expectRevert("PsyNFT: Initial Mint Complete");
        psyNFT.initialMint();
    }

    function test_InitialMintWorks() public {
        assertEq(psyNFT.previousFibonacci(), 3);
        assertEq(psyNFT.tokenId(), 0);
        assertEq(psyNFT.initialMintCalled(), false);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 0);

        vm.prank(address(core));
        psyNFT.initialMint();

        assertEq(psyNFT.previousFibonacci(), 3);
        assertEq(psyNFT.tokenId(), 5);
        assertEq(psyNFT.initialMintCalled(), true);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 5);
    }
}
