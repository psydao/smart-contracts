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
        sublicencesNft.setCoreContract(address(core));
    }

    function test_FailsIfCoreIsAddressZero() public {
        vm.prank(owner);
        vm.expectRevert("NFTSublicences: Cannot Be Zero Address");
        sublicencesNft.setCoreContract(address(0));
    }

    function test_SetsCoreContractCorrectly() public {
        assertEq(sublicencesNft.core(), address(core));
        vm.prank(owner);
        sublicencesNft.setCoreContract(address(alice));
        assertEq(sublicencesNft.core(), address(alice));
    }
}
