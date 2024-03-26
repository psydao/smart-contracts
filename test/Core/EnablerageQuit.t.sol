// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";
import "../../src/PsyNFT.sol";


contract EnableRageQuitTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfCallerIsNotContractOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        core.enableRageQuit();
    }

    function test_FailsIfRageQuitAlreadyEnabled() public {
        vm.startPrank(owner);
        core.enableRageQuit();

        vm.expectRevert("Core: Rage Quit Already Enabled");
        core.enableRageQuit();
    }

    function test_EnablesRageQuit() public {
        assertEq(core.rageQuitAllowed(), false);

        vm.prank(owner);
        core.enableRageQuit();
        assertEq(core.rageQuitAllowed(), true);
    }
}