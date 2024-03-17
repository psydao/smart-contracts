// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract ResumeSaleTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfNotOwner() public {
        psyToken.mint(address(tokenSale), 10e18);
        
        vm.startPrank(owner);
        tokenSale.pauseSale();
        tokenSale.setSupply();

        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        tokenSale.resumeSale();
    }

    function test_FailsIfSaleNotPaused() public {
        psyToken.mint(address(tokenSale), 10e18);

        vm.startPrank(owner);
        tokenSale.setSupply();

        vm.expectRevert("PsyToken: Token Not Paused");
        tokenSale.resumeSale();
    }

    function test_FailsIfSupplyNotBiggerThan0() public {
        vm.startPrank(owner);
        tokenSale.pauseSale();
        vm.expectRevert("PsyToken: Supply Finished");
        tokenSale.resumeSale();
    }

    function test_SaleSuccessfullyResumes() public {
        psyToken.mint(address(tokenSale), 10e18);

        assertEq(tokenSale.saleActive(), true);
        vm.startPrank(owner);
        tokenSale.setSupply();
        tokenSale.pauseSale();
        tokenSale.resumeSale();
        assertEq(tokenSale.saleActive(), true);
    }
}
