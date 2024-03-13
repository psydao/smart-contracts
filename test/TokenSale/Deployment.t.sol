// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract TokenSaleDeploymentTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_VariablesInitializedCorrectly() public {
        assertEq(address(tokenSale.psyToken()), address(psyToken));
        assertEq(address(tokenSale.usdc()), address(usdc));
    }
}