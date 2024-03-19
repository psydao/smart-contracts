// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";
import "../../src/PsyNFT.sol";


contract TransferNftsToAuctionTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_TransferFailsIfNotContractOwner() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 2;
        tokenIds[1] = 4;

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        core.transferNftsToAuction(tokenIds);
    }

    function test_TransferToAuction() public {
        vm.prank(owner);
        core.mintInitialBatch();

        uint256[] memory tokenIdsForAuction = new uint256[](2);
        tokenIdsForAuction[0] = 2;
        tokenIdsForAuction[1] = 4;
        assertEq(psyNFT.ownerOf(2), address(psyNFT));
        assertEq(psyNFT.ownerOf(4), address(psyNFT));

        vm.prank(owner);
        core.transferNftsToAuction(tokenIdsForAuction);
        
        assertEq(psyNFT.ownerOf(0), address(psyNFT));
        assertEq(psyNFT.ownerOf(2), address(auction));
        assertEq(psyNFT.ownerOf(4), address(auction));
    }

    
}
