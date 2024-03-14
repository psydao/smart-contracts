// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract UnlockTokenTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfNotOwner() public {
        vm.startPrank(owner);
        tokenSale.pauseSale();

        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        tokenSale.unlockToken();
    }

    function test_FailsIfSaleNotPaused() public {
        vm.startPrank(owner);
        vm.expectRevert("PsyToken: Token Not Paused");
        tokenSale.unlockToken();
    }

    function test_SaleSuccessfullyResumes() public {
        assertEq(uint256(tokenSale.saleStatus()), 0);
        vm.startPrank(owner);
        tokenSale.pauseSale();
        tokenSale.unlockToken();
        assertEq(uint256(tokenSale.saleStatus()), 2);
    }
}
