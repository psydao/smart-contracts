// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract DisableControlledTransfersTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfCallerIsNotContractOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        psyNFT.disableControlledTransfers();
    }

    function test_FailsIfAlreadyDisabled() public {
        vm.startPrank(owner);
        psyNFT.disableControlledTransfers();

        vm.expectRevert("PsyNFT: Controlled Transfers Already Disabled");
        psyNFT.disableControlledTransfers();
    }

    function test_DisablesControlledTransfers() public {
        assertEq(psyNFT.controlledTransfers(), true);

        vm.prank(owner);
        psyNFT.disableControlledTransfers();
        
        assertEq(psyNFT.controlledTransfers(), false);
    }
}
