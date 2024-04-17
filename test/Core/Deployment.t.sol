// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";
import "../../src/PsyNFT.sol";


contract CoreDeploymentTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfPsyNftIsAddressZero() public {
        vm.prank(owner);
        vm.expectRevert("Core: Cannot Be Zero Address");
        Core coreContract = new Core(address(0), address(sublicencesNft), address(treasury));
    }

    function test_FailsIfSublicencesNftIsAddressZero() public {
        vm.prank(owner);
        vm.expectRevert("Core: Cannot Be Zero Address");
        Core coreContract = new Core(address(psyNFT), address(0), address(treasury));
    }

    function test_FailsIfTreasuryIsAddressZero() public {
        vm.prank(owner);
        vm.expectRevert("Core: Cannot Be Zero Address");
        Core coreContract = new Core(address(psyNFT), address(sublicencesNft), address(0));
    }

    function test_VariablesInitializedCorrectly() public {
        vm.prank(owner);
        Core coreContract = new Core(address(psyNFT), address(sublicencesNft), address(treasury));

        assertEq(address(coreContract.psyNFT()), address(psyNFT));
        assertEq(address(coreContract.treasury()), address(treasury));
        assertEq(coreContract.owner(), address(owner));
    }
}
