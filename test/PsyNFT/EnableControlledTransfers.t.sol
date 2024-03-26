// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract EnableControlledTransfersTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfCallerIsNotContractOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        psyNFT.disableControlledTransfers();
    }

    function test_FailsIfAlreadyEnabled() public {
        vm.prank(owner);
        vm.expectRevert("PsyNFT: Controlled Transfers Already Enabled");
        psyNFT.enableControlledTransfers();
    }

    function test_EnablesControlledTransfers() public {
        vm.startPrank(owner);
        psyNFT.disableControlledTransfers();

        assertEq(psyNFT.controlledTransfers(), false);

        psyNFT.enableControlledTransfers();
        assertEq(psyNFT.controlledTransfers(), true);
    }
}
