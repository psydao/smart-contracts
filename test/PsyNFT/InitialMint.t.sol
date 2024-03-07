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
}
