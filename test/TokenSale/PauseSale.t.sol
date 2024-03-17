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

        vm.expectRevert("PsyToken: Token Already Paused");
        tokenSale.pauseSale();
    }

    function test_SaleSuccessfullyPauses() public {
        assertEq(tokenSale.saleActive(), true);
        vm.startPrank(owner);
        tokenSale.pauseSale();
        assertEq(tokenSale.saleActive(), false);
    }
}
