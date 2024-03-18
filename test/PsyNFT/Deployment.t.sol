// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract PsyNFTDeploymentTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_VariablesInitializedCorrectly() public {
        assertEq(psyNFT.name(), "PsyNFT");
        assertEq(psyNFT.symbol(), "PSY");
        assertEq(psyNFT.owner(), address(owner));
        assertEq(psyNFT.initialMintCalled(), false);
        assertEq(psyNFT.controlledTransfers(), true);
    }
}
