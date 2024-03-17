// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract TokenSaleDeploymentTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfPsyTokenIsAddressZero() public {
        vm.expectRevert("Cannot be address 0");
        TokenSale testTokenSale = new TokenSale(address(0), 0.1 ether);
    }

    function test_VariablesInitializedCorrectly() public {
        assertEq(address(tokenSale.psyToken()), address(psyToken));
        assertEq(tokenSale.tokenPriceInETH(), 0.1 ether);
        assertEq(tokenSale.saleActive(), true);
        assertEq(tokenSale.tokensLocked(), true);
    }
}