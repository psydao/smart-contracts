// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract ApproveTransferTest is TestSetup {

    uint256[] public tokens = new uint256[](3);

    function setUp() public {
        setUpTests();
        vm.prank(owner);
        core.mintInitialBatch();

        tokens[0] = 0;
        tokens[1] = 2;
        tokens[2] = 3;
    }

    function test_FailsIfNotCalledByCoreContract() public {
        vm.prank(alice);
        vm.expectRevert("PsyNFT: Caller Not Core Contract");
        psyNFT.approveTransfer(2, address(owner), 400);
    }

    function test_FailsIfTokenDoesNotExist() public {
        transferNftToUser(address(alice), tokens);        
        vm.prank(address(core));
        vm.expectRevert("PsyNFT: Non Existent Token");
        psyNFT.approveTransfer(9, address(owner), 400);
    }

    function test_FailsIfApprovalAlreadyExists() public {
        transferNftToUser(address(alice), tokens);        
        vm.startPrank(address(core));
        psyNFT.approveTransfer(2, address(bob), 400);

        vm.expectRevert("PsyNFT: Transfer Request Currently Active");
        psyNFT.approveTransfer(2, address(owner), 400);
    }

    function test_ApprovingTransferWorksCorrectly() public {
        transferNftToUser(address(alice), tokens);        

        (, uint256 initialTransferExpiryDate,) = psyNFT.approvedTransfers(2);
        
        assertEq(initialTransferExpiryDate, 0);
        
        vm.prank(address(core));
        psyNFT.approveTransfer(2, address(bob), 400);

        (
            uint256 tokenId, 
            uint256 transferExpiryDate,
            address to
        ) = psyNFT.approvedTransfers(2);

        assertEq(tokenId, 2);
        assertEq(to, address(bob));
        assertEq(transferExpiryDate, 401);
    }
}
