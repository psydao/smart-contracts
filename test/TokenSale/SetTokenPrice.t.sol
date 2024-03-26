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
        tokenSale.setTokenPrice(0.01 ether);
    }

    function test_FailsIfNewPriceIsSameAsCurrentPrice() public {
        vm.startPrank(owner);
        vm.expectRevert("TokenSale: New Token Price Same As Current");
        tokenSale.setTokenPrice(0.1 ether);
    }

    function test_TokenPriceCorrectlyUpdates() public {
        assertEq(tokenSale.tokenPriceInDollar(), 0.1 ether);
        vm.startPrank(owner);
        tokenSale.setTokenPrice(10 ether);
        assertEq(tokenSale.tokenPriceInDollar(), 10 ether);
    }
}
