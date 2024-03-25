// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";
import "../../src/PsyNFT.sol";


contract TransferNftsToUserTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_TransferFailsIfNotContractOwner() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 2;
        tokenIds[1] = 4;

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        core.transferNftsToUser(tokenIds, address(alice));
    }

    function test_TransferToUser() public {
        vm.prank(owner);
        core.mintInitialBatch();

        uint256[] memory tokenIdsForUser = new uint256[](2);
        tokenIdsForUser[0] = 2;
        tokenIdsForUser[1] = 4;
        assertEq(psyNFT.ownerOf(2), address(psyNFT));
        assertEq(psyNFT.ownerOf(4), address(psyNFT));

        vm.prank(owner);
        core.transferNftsToUser(tokenIdsForUser, address(alice));
        
        assertEq(psyNFT.ownerOf(0), address(psyNFT));
        assertEq(psyNFT.ownerOf(2), address(alice));
        assertEq(psyNFT.ownerOf(4), address(alice));
    }
}
