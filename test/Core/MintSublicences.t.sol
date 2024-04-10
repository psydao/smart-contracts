// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract MintSublicencesTest is TestSetup {

    function setUp() public {
        setUpTests();

        vm.prank(owner);
        core.mintInitialBatch();

        uint256[] memory tokensForAlice = new uint256[](3);
        tokensForAlice[0] = 0;
        tokensForAlice[1] = 1;
        tokensForAlice[2] = 2;

        transferNftToUser(address(alice), tokensForAlice);
    }

    function test_FailsIfMintingLessThan1() public {
        vm.prank(alice);
        vm.expectRevert("Core: Cannot Mint Less Than 1");
        core.mintSublicenses(2, 0);
    }

    function test_MintSublicencingWorks() public {

        assertEq(sublicencesNft.balanceOf(address(alice), 2), 0);
        vm.prank(alice);
        core.mintSublicenses(2, 100);
        assertEq(sublicencesNft.balanceOf(address(alice), 2), 100);

        assertEq(sublicencesNft.balanceOf(address(alice), 1), 0);
        vm.prank(alice);
        core.mintSublicenses(1, 12000);
        assertEq(sublicencesNft.balanceOf(address(alice), 1), 12000);

        vm.prank(alice);
        sublicencesNft.safeTransferFrom(address(alice), address(bob), 1, 11000, "");

        assertEq(sublicencesNft.balanceOf(address(alice), 2), 100);
        assertEq(sublicencesNft.balanceOf(address(bob), 2), 0);
        assertEq(sublicencesNft.balanceOf(address(alice), 1), 1000);
        assertEq(sublicencesNft.balanceOf(address(bob), 1), 11000);
    }
}
