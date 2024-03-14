// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract TokenSaleDeploymentTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfPsyTokenIsAddressZero() public {
        vm.expectRevert("Cannot be address 0");
        TokenSale testTokenSale = new TokenSale(address(0), address(usdc), 10e17);
    }

    function test_FailsIfUSDCIsAddressZero() public {
        vm.expectRevert("Cannot be address 0");
        TokenSale testTokenSale = new TokenSale(address(psyToken), address(0), 10e17);
    }

    function test_VariablesInitializedCorrectly() public {
        assertEq(address(tokenSale.psyToken()), address(psyToken));
        assertEq(address(tokenSale.usdc()), address(usdc));
    }
}