// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract NFTSublicencesDeploymentTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_VariablesInitializedCorrectly() public {
        vm.prank(owner);
        NFTSublicences sublicenceContract = new NFTSublicences(address(psyNFT), "MetaData.xt");

        assertEq(sublicenceContract.core(), address(0));
        assertEq(sublicenceContract.uri(2), "MetaData.xt");
        assertEq(sublicenceContract.owner(), address(owner));
    }
}
