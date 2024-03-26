// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";
import "../../src/PsyNFT.sol";


contract DisablerageQuitTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfCallerIsNotContractOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        core.disableRageQuit();
    }

    function test_FailsIfRageQuitAlreadyDisabled() public {
        vm.prank(owner);
        vm.expectRevert("Core: Rage Quit Already Disabled");
        core.disableRageQuit();
    }

    function test_DisablesRageQuit() public {
        assertEq(core.rageQuitAllowed(), false);

        vm.startPrank(owner);
        core.enableRageQuit();

        assertEq(core.rageQuitAllowed(), true);

        core.disableRageQuit();

        assertEq(core.rageQuitAllowed(), false);
    }
}
