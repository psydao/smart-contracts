// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";
import "../TestERC20.sol";

contract BuyTokensTest is TestSetup {

    TestERC20 public testToken;

    function setUp() public {
        setUpTests();
        testToken = new TestERC20("TestERC20", "T20");
    }

    function test_BuyTokensWorksCorrectly() public {
        assertEq(testToken.balanceOf(address(alice)), 0);
        vm.prank(alice);
        testToken.mint(address(alice), 100);
        assertEq(testToken.balanceOf(address(alice)), 100);
    }
}
