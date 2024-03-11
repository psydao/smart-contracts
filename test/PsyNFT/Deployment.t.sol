// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract PsyNFTDeploymentTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_VariablesInitializedCorrectly() public {
        vm.prank(owner);
        PsyNFT psyNFTContract = new PsyNFT();

        assertEq(psyNFTContract.name(), "PsyNFT");
        assertEq(psyNFTContract.symbol(), "PSY");
        assertEq(psyNFTContract.owner(), address(owner));
    }
}
