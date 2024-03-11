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
        vm.expectRevert("Cannot be address 0");
        Core coreContract = new Core(address(0), address(auction));
    }

    function test_FailsIfAuctionIsAddressZero() public {
        vm.prank(owner);
        vm.expectRevert("Cannot be address 0");
        Core coreContract = new Core(address(psyNFT), address(0));
    }

    function test_VariablesInitializedCorrectly() public {
        vm.prank(owner);
        Core coreContract = new Core(address(psyNFT), address(auction));

        assertEq(address(coreContract.psyNFT()), address(psyNFT));
        assertEq(coreContract.auctionContract(), address(auction));
        assertEq(coreContract.owner(), address(owner));
    }
}
