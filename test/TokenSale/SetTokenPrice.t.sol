// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract SetTokenPrice is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfNotOwner() public {
        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        tokenSale.setTokenPrice(10e16);
    }

    function test_FailsIfNewPriceIsSameAsCurrentPrice() public {
        vm.startPrank(owner);
        vm.expectRevert("PsyToken: New Token Price Same As Current");
        tokenSale.setTokenPrice(10e17);
    }

    function test_TokenPriceCorrectlyUpdates() public {
        assertEq(tokenSale.tokenPriceInUsdc(), 10e17);
        vm.startPrank(owner);
        tokenSale.setTokenPrice(10e19);
        assertEq(tokenSale.tokenPriceInUsdc(), 10e19);
    }
}
