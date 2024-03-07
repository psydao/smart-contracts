// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";
import "../../src/PsyNFT.sol";

contract InitialMintTest is TestSetup {

    function setUp() public {
       setUpTests();
    }

    function test_InitialMintFailsWhenNotOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        psyNFT.initialMint();
    }

    function test_InitialMintFailsWhenAlreadyCalled() public {
         vm.startPrank(owner);
        psyNFT.initialMint();
        vm.expectRevert("Initial mint completed");
        psyNFT.initialMint();
    }

    function test_InitialMintWorks() public {
        assertEq(psyNFT.secondLastFibonacci(), 0);
        assertEq(psyNFT.previousFibonacci(), 0);
        assertEq(psyNFT.tokenId(), 0);
        assertEq(psyNFT.initialMintCalled(), false);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 0);

        vm.prank(owner);
        psyNFT.initialMint();

        assertEq(psyNFT.secondLastFibonacci(), 1);
        assertEq(psyNFT.previousFibonacci(), 2);
        assertEq(psyNFT.tokenId(), 5);
        assertEq(psyNFT.initialMintCalled(), true);
        assertEq(psyNFT.balanceOf(address(psyNFT)), 5);
    }
}
