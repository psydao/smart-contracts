// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";
import "../../src/PsyNFT.sol";


contract TransferNFTsTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_TransferFailsIfNotOwner() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 2;
        tokenIds[1] = 4;

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        psyNFT.transferNFTs(tokenIds, address(auction));
    }

    function test_TransferFailsIfRecipientIsZeroAddress() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 2;
        tokenIds[1] = 4;

        vm.prank(owner);
        vm.expectRevert("Cannot be address 0");
        psyNFT.transferNFTs(tokenIds, address(0));
    }

    function test_transferFailsIfTokenIdIsInvalid() public {
        vm.startPrank(owner);

        psyNFT.initialMint();

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 2;
        tokenIds[1] = 6;

        vm.expectRevert(abi.encodeWithSelector(ERC721NonexistentToken.selector, 6));
        psyNFT.transferNFTs(tokenIds, address(auction));
    }

    function test_transferFailsIfTokenIdIsNotOwnedByContract() public {
        vm.startPrank(owner);

        psyNFT.initialMint();

        uint256[] memory tokensForAlice = new uint[](1);
        tokensForAlice[0] = 1;

        psyNFT.transferNFTs(tokensForAlice, address(alice));

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 1;
        tokenIds[1] = 4;

        vm.expectRevert(abi.encodeWithSelector(ERC721IncorrectOwner.selector, address(psyNFT), 1, address(alice)));
        psyNFT.transferNFTs(tokenIds, address(auction));
    }

    function test_TransferFromUserFailsIfNotApproved() public {
        vm.startPrank(owner);

        psyNFT.initialMint();

        uint256[] memory tokens = new uint256[](2);
        tokens[0] = 2;
        tokens[1] = 4;
        psyNFT.transferNFTs(tokens, address(alice));
        vm.stopPrank();

        vm.prank(alice);
        vm.expectRevert("Transfer of token not approved");
        psyNFT.safeTransferFrom(address(alice), address(bob), 2);
    }

    function test_TransferFromUserFailsIfDeclinedByOwner() public {
        uint256 TWO_DAYS = 172800;

        vm.startPrank(owner);

        psyNFT.initialMint();

        uint256[] memory tokens = new uint256[](2);
        tokens[0] = 2;
        tokens[1] = 4;
        psyNFT.transferNFTs(tokens, address(alice));
        vm.stopPrank();

        vm.prank(alice);
        psyNFT.submitTransferRequest(address(bob), 2);

        vm.prank(owner);
        psyNFT.finalizeRequest(2, false);

        vm.prank(alice);
        vm.expectRevert("Transfer of token not approved");
        psyNFT.safeTransferFrom(address(alice), address(bob), 2);
    }

    function test_TransferFromUserFailsIfApprovalHasExpired() public {
        uint256 TWO_DAYS = 172800;

        vm.startPrank(owner);

        psyNFT.initialMint();

        uint256[] memory tokens = new uint256[](2);
        tokens[0] = 2;
        tokens[1] = 4;
        psyNFT.transferNFTs(tokens, address(alice));
        vm.stopPrank();

        vm.prank(alice);
        psyNFT.submitTransferRequest(address(bob), 2);

        vm.prank(owner);
        psyNFT.finalizeRequest(2, true);

        vm.warp(TWO_DAYS);

        vm.prank(alice);
        vm.expectRevert("Request expired");
        psyNFT.safeTransferFrom(address(alice), address(bob), 2);
    }

    function test_TransferFromUserFailsIfReceiversAreDifferent() public {
        uint256 TWO_DAYS = 172800;

        vm.startPrank(owner);

        psyNFT.initialMint();

        uint256[] memory tokens = new uint256[](2);
        tokens[0] = 2;
        tokens[1] = 4;
        psyNFT.transferNFTs(tokens, address(alice));
        vm.stopPrank();

        vm.prank(alice);
        psyNFT.submitTransferRequest(address(bob), 2);

        vm.prank(owner);
        psyNFT.finalizeRequest(2, true);

        vm.prank(alice);
        vm.expectRevert("Different receivers");
        psyNFT.safeTransferFrom(address(alice), address(owner), 2);
    }

    function test_TransferWithApproval() public {
        uint256 TWO_DAYS = 172800;

        vm.startPrank(owner);

        psyNFT.initialMint();

        uint256[] memory tokens = new uint256[](2);
        tokens[0] = 2;
        tokens[1] = 4;
        psyNFT.transferNFTs(tokens, address(alice));
        vm.stopPrank();

        vm.prank(alice);
        psyNFT.submitTransferRequest(address(bob), 2);

        vm.prank(owner);
        psyNFT.finalizeRequest(2, true);

        assertEq(psyNFT.ownerOf(2), address(alice));
        vm.prank(alice);
        psyNFT.safeTransferFrom(address(alice), address(bob), 2);
        assertEq(psyNFT.ownerOf(2), address(bob));
    }

    function test_TransferNfts() public {
        vm.startPrank(owner);

        psyNFT.initialMint();

        uint256[] memory tokenIdsForAuction = new uint256[](2);
        tokenIdsForAuction[0] = 2;
        tokenIdsForAuction[1] = 4;
        assertEq(psyNFT.ownerOf(2), address(psyNFT));
        psyNFT.transferNFTs(tokenIdsForAuction, address(auction));
        
        assertEq(psyNFT.ownerOf(0), address(psyNFT));
        assertEq(psyNFT.ownerOf(2), address(auction));
        assertEq(psyNFT.ownerOf(4), address(auction));
    }
}
