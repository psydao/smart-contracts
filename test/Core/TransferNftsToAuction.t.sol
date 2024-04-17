// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";
import "../../src/PsyNFT.sol";
import "../../src/Auction.sol";


contract TransferNftsToAuctionTest is TestSetup {

    function setUp() public {
        setUpTests();
        auction = new Auction();
        vm.prank(owner);
        core.setAuctionContract(address(auction));
    }

    function test_TransferFailsIfNotContractOwner() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 1;
        tokenIds[1] = 2;

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        core.transferNftsToAuction(tokenIds);
    }

    function test_TransferToAuction() public {
        vm.prank(owner);
        core.mintInitialBatch();

        uint256[] memory tokenIdsForAuction = new uint256[](2);
        tokenIdsForAuction[0] = 1;
        tokenIdsForAuction[1] = 2;
        assertEq(psyNFT.ownerOf(1), address(psyNFT));
        assertEq(psyNFT.ownerOf(2), address(psyNFT));

        vm.prank(owner);
        core.transferNftsToAuction(tokenIdsForAuction);
        
        assertEq(psyNFT.ownerOf(0), address(psyNFT));
        assertEq(psyNFT.ownerOf(1), address(auction));
        assertEq(psyNFT.ownerOf(2), address(auction));
    }

    
}
