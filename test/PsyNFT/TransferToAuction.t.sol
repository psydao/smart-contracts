// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";
import "../../src/PsyNFT.sol";


contract TransferToAuctionTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_TransferToAuctionFailsIfNotOwner() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 2;
        tokenIds[1] = 4;

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        psyNFT.transferNFTs(tokenIds, address(auction));
    }

    function test_TransferToAuctionFailsIfAuctionIsZeroAddress() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 2;
        tokenIds[1] = 4;

        vm.prank(owner);
        vm.expectRevert("Cannot be address 0");
        psyNFT.transferNFTs(tokenIds, address(0));
    }

    function test_TransferNfts() public {
        vm.startPrank(owner);
        psyNFT.initialMint();

        uint256[] memory tokenIdsForAuction = new uint256[](2);
        tokenIdsForAuction[0] = 2;
        tokenIdsForAuction[1] = 4;

        uint256[] memory tokenIdsForBob = new uint256[](2);
        tokenIdsForBob[0] = 1;
        tokenIdsForBob[1] = 3;

        assertEq(psyNFT.ownerOf(0), address(psyNFT));
        assertEq(psyNFT.ownerOf(1), address(psyNFT));
        assertEq(psyNFT.ownerOf(2), address(psyNFT));
        assertEq(psyNFT.ownerOf(3), address(psyNFT));
        assertEq(psyNFT.ownerOf(4), address(psyNFT));

        psyNFT.transferNFTs(tokenIdsForAuction, address(auction));
        
        assertEq(psyNFT.ownerOf(0), address(psyNFT));
        assertEq(psyNFT.ownerOf(1), address(psyNFT));
        assertEq(psyNFT.ownerOf(2), address(auction));
        assertEq(psyNFT.ownerOf(3), address(psyNFT));
        assertEq(psyNFT.ownerOf(4), address(auction));

        psyNFT.transferNFTs(tokenIdsForBob, address(bob));

        assertEq(psyNFT.ownerOf(0), address(psyNFT));
        assertEq(psyNFT.ownerOf(1), address(bob));
        assertEq(psyNFT.ownerOf(2), address(auction));
        assertEq(psyNFT.ownerOf(3), address(bob));
        assertEq(psyNFT.ownerOf(4), address(auction));
    }
}
