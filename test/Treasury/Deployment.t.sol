// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract DeploymentTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfPsyNftIsZeroAddress() public {
        vm.prank(address(owner));
        vm.expectRevert("Treasury: Cannot Be Zero Address");
        Treasury treasuryInstance = new Treasury(address(0));
    }

    function test_VariablesInitializedCorrectly() public {
        assertEq(address(treasury.psyNFT()), address(psyNFT));
        assertEq(treasury.core(), address(core));
        assertEq(treasury.ethBalance(), 0);
    }
}
