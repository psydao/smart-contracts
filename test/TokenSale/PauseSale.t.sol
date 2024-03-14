// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract PauseSaleTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfNotOwner() public {
        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        tokenSale.pauseSale();
    }

    function test_FailsIfSaleNotOpen() public {
        vm.startPrank(owner);
        tokenSale.pauseSale();

        vm.expectRevert("PsyToken: Token Not Open");
        tokenSale.pauseSale();
    }

    function test_SaleSuccessfullyPauses() public {
        assertEq(uint256(tokenSale.saleStatus()), 0);
        vm.startPrank(owner);
        tokenSale.pauseSale();
        assertEq(uint256(tokenSale.saleStatus()), 1);
    }
}
