// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract ResumeSaleTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfNotOwner() public {
        psyToken.mint(address(owner), 10 ether);
        vm.startPrank(owner);
        psyToken.approve(address(tokenSale), 10 ether);
        tokenSale.depositPsyTokensForSale(10 ether);
        tokenSale.pauseSale();
        vm.stopPrank();

        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        tokenSale.resumeSale();
    }

    function test_FailsIfSaleNotPaused() public {
        psyToken.mint(address(owner), 10 ether);
        vm.startPrank(owner);
        psyToken.approve(address(tokenSale), 10 ether);
        tokenSale.depositPsyTokensForSale(10 ether);

        vm.expectRevert("TokenSale: Token Not Paused");
        tokenSale.resumeSale();
    }

    function test_FailsIfSupplyNotBiggerThan0() public {
        vm.startPrank(owner);
        tokenSale.pauseSale();
        vm.expectRevert("TokenSale: Supply Finished");
        tokenSale.resumeSale();
    }

    function test_SaleSuccessfullyResumes() public {
        psyToken.mint(address(owner), 10 ether);
        vm.startPrank(owner);
        psyToken.approve(address(tokenSale), 10 ether);
        tokenSale.depositPsyTokensForSale(10 ether);
        vm.stopPrank();

        assertEq(tokenSale.saleActive(), true);
        vm.startPrank(owner);
        tokenSale.pauseSale();
        tokenSale.resumeSale();
        assertEq(tokenSale.saleActive(), true);
    }
}
