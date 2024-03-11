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
