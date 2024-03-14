// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract SetSupplyTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfNotOwner() public {
        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        tokenSale.setSupply();
    }

    function test_SetsSupply() public {
        psyToken.mint(address(tokenSale), 10e18);

        assertEq(tokenSale.supply(), 0);
        vm.startPrank(owner);
        tokenSale.setSupply();
        assertEq(tokenSale.supply(), 10e18);
    }
}
