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
        psyNFT.setCoreContract(address(core));
    }

    function test_FailsIfCoreIsAddressZero() public {
        vm.prank(owner);
        vm.expectRevert("Cannot be address 0");
        psyNFT.setCoreContract(address(0));
    }

    function test_SetsCoreContractCorrectly() public {
        assertEq(psyNFT.core(), address(core));
        vm.prank(owner);
        psyNFT.setCoreContract(address(alice));
        assertEq(psyNFT.core(), address(alice));
    }
}
