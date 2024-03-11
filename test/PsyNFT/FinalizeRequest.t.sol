// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract FinalizeRequestTest is TestSetup {

    function setUp() public {
        setUpTests();
        vm.prank(owner);
        psyNFT.initialMint();

        uint256[] memory tokensForAlice = new uint256[](3);
        tokensForAlice[0] = 0;
        tokensForAlice[1] = 2;
        tokensForAlice[2] = 3;

        uint256[] memory tokensForBob = new uint256[](1);
        tokensForBob[0] = 1;

        transferNftToUser(address(alice), tokensForAlice);
        transferNftToUser(address(bob), tokensForBob);
        createTransferRequest(2);
    }

    function test_RevertIfNotContractOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        psyNFT.finalizeRequest(2, true);
    }

    function test_RevertWhenRequestDoesNotExist() public {
        vm.prank(owner);
        vm.expectRevert("Request non existent");
        psyNFT.finalizeRequest(1, true);
    }

    function test_RevertWhenRequestHasExpired() public {
        uint256 TWO_DAYS = 172800;
        vm.prank(owner);
        vm.warp(TWO_DAYS);
        vm.expectRevert("Request expired");
        psyNFT.finalizeRequest(2, true);
    }

    function test_ApproveARequest() public {
        vm.prank(owner);
        psyNFT.finalizeRequest(2, true);

        (,,,, bool approved) = psyNFT.transferRequests(2);
        assertEq(approved, true);
    }

    function test_DeclineARequest() public {
        vm.prank(owner);
        psyNFT.finalizeRequest(2, false);

        (,,,, bool approved) = psyNFT.transferRequests(2);
        assertEq(approved, false);
    }

    function transferNftToUser(address _user, uint256[] memory _tokens) public {
        vm.prank(address(core));
        psyNFT.transferNFTs(_tokens, _user);
    }

    function createTransferRequest(uint256 _tokenId) public {
        vm.prank(alice);
        psyNFT.submitTransferRequest(address(bob), _tokenId);
    }
}
