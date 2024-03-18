// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract ApprovePsyNftTransferTest is TestSetup {

    function setUp() public {
        setUpTests();
        vm.prank(owner);
        psyNFT.initialMint();
    }

    function test_FailsIfNotContractOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        psyNFT.approvePsyNftTransfer(2, address(owner), 400);
    }

    function test_FailsIfTokenDoesNotExist() public {
        transferNftToUser(address(alice));        
        vm.prank(owner);
        vm.expectRevert("PsyNFT: Non Existent Token");
        psyNFT.approvePsyNftTransfer(9, address(owner), 400);
    }

    function test_FailsIfApprovalAlreadyExists() public {
        transferNftToUser(address(alice));
        vm.startPrank(owner);
        psyNFT.approvePsyNftTransfer(2, address(bob), 400);

        vm.expectRevert("PsyNFT: Transfer Request Currently Active");
        psyNFT.approvePsyNftTransfer(2, address(owner), 400);
    }

    function test_ApprovingTransferWorksCorrectly() public {
        transferNftToUser(address(alice));

        (,, uint256 initialTransferExpiryDate) = psyNFT.approvedTransfers(2);
        
        assertEq(initialTransferExpiryDate, 0);
        
        vm.prank(owner);
        psyNFT.approvePsyNftTransfer(2, address(bob), 400);

        (
            uint256 tokenId, 
            address to,
            uint256 transferExpiryDate
        ) = psyNFT.approvedTransfers(2);

        assertEq(tokenId, 2);
        assertEq(to, address(bob));
        assertEq(transferExpiryDate, 401);
    }

    function transferNftToUser(address _user) public {
        uint256[] memory tokens = new uint256[](3);
        tokens[0] = 0;
        tokens[1] = 2;
        tokens[2] = 3;

        vm.prank(address(core));
        psyNFT.transferNFTs(tokens, _user);
    }
}
