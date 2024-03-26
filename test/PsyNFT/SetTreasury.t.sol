// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract SetTreasuryContractTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfCallerIsNotContractOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        psyNFT.setTreasury(address(treasury));
    }

    function test_FailsIfTreasuryIsAddressZero() public {
        vm.prank(owner);
        vm.expectRevert("PsyNFT: Treasury Cannot Be Zero Address");
        psyNFT.setTreasury(address(0));
    }

    function test_SetsTreasuryContractCorrectly() public {
        assertEq(psyNFT.treasury(), address(treasury));
        vm.prank(owner);
        psyNFT.setTreasury(address(alice));
        assertEq(psyNFT.treasury(), address(alice));
    }
}
