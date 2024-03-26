// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract NFTSublicencesDeploymentTest is TestSetup {

    function setUp() public {
        setUpTests();

        vm.prank(owner);
        core.mintInitialBatch();

        uint256[] memory tokensForAlice = new uint256[](3);
        tokensForAlice[0] = 0;
        tokensForAlice[1] = 2;
        tokensForAlice[2] = 3;

        transferNftToUser(address(alice), tokensForAlice);
    }

    function test_FailsIfCallerNotCoreContract() public {
        vm.prank(owner);
        vm.expectRevert("NFTSublicences: Caller Not Core Contract");
        sublicencesNft.mint(address(alice), 2, 100);
    }

    function test_FailsIfMinterIsNotTokenHolder() public {
        vm.prank(address(core));
        vm.expectRevert("NFTSublicences: Not Token Holder");
        sublicencesNft.mint(address(bob), 2, 100);
    }

    function test_MintNewSublicences() public {
        uint256 ERC721_ID = 2;
        
        assertEq(sublicencesNft.balanceOf(address(alice), ERC721_ID), 0);
        vm.prank(address(core));
        sublicencesNft.mint(address(alice), ERC721_ID, 100);
        assertEq(sublicencesNft.balanceOf(address(alice), ERC721_ID), 100);
    }
}
