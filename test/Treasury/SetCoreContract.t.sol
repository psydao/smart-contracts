// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract SetCoreContractTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfCallerIsNotContractOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        treasury.setCoreContract(address(core));
    }

    function test_FailsIfCoreIsAddressZero() public {
        vm.prank(owner);
        vm.expectRevert("Treasury: Cannot Be Zero Address");
        treasury.setCoreContract(address(0));
    }

    function test_SetsCoreContractCorrectly() public {
        assertEq(treasury.core(), address(core));
        vm.prank(owner);
        treasury.setCoreContract(address(alice));
        assertEq(treasury.core(), address(alice));
    }
}
