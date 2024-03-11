// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";
import "../../src/PsyNFT.sol";


contract SubmitTransferRequestTest is TestSetup {

    function setUp() public {
        setUpTests();
        vm.prank(owner);
        psyNFT.initialMint();

    }

    function test_SubmittingRequestFailsIfNonTokenOwner() public {
        vm.prank(alice);
        vm.expectRevert("Not token owner");
        psyNFT.submitTransferRequest(address(owner), 2);
    }

    function test_SubmittingRequestFailsIfToAddressZero() public {
        transferNftToUser(address(alice));
        vm.prank(alice);
        vm.expectRevert("Cannot be address 0");
        psyNFT.submitTransferRequest(address(0), 2);
    }

    function test_SubmittingRequestFailsIfRequestAlreadyExists() public {
        transferNftToUser(address(alice));
        vm.startPrank(alice);
        psyNFT.submitTransferRequest(address(bob), 2);

        vm.expectRevert("Transfer request currently active");
        psyNFT.submitTransferRequest(address(owner), 2);
    }

    function test_SubmittingTransferRequestIsSuccessful() public {
        transferNftToUser(address(alice));

        (, uint256 requestEndTime,,,) = psyNFT.transferRequests(2);
        
        assertEq(requestEndTime, 0);
        
        vm.prank(alice);
        psyNFT.submitTransferRequest(address(bob), 2);

        (
            uint256 tokenId, 
            uint256 endTime,
            address from,
            address to,
            bool approved
        ) = psyNFT.transferRequests(2);

        assertEq(tokenId, 2);
        assertEq(endTime, 86401);
        assertEq(from, address(alice));
        assertEq(to, address(bob));
        assertEq(approved, false);
    }

    function transferNftToUser(address _user) public {
        uint256[] memory tokens = new uint256[](3);
        tokens[0] = 0;
        tokens[1] = 2;
        tokens[2] = 3;

        vm.prank(owner);
        psyNFT.transferNFTs(tokens, _user);
    }
}
