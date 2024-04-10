// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract WithdrawFundsAsPsyDaoTest is TestSetup {

    function setUp() public {
        setUpTests();

        vm.prank(owner);
        core.mintInitialBatch();

        uint256[] memory tokensForAlice = new uint256[](3);
        tokensForAlice[0] = 0;
        tokensForAlice[1] = 1;
        tokensForAlice[2] = 2;

        transferNftToUser(address(alice), tokensForAlice);

        vm.deal(address(alice), 10 ether);
        vm.prank(alice);
        (bool sent, ) = address(treasury).call{value: 5 ether}("");
    }

    function test_FailsIfNotContractOwner() public {
        vm.prank(address(alice));
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        treasury.withdrawFundsAsPsyDao(address(owner), 2 ether);
    }

    function test_FailsIfReceiverIsAddressZero() public {
        vm.prank(address(owner));
        vm.expectRevert("Treasury: Cannot Be Zero Address");
        treasury.withdrawFundsAsPsyDao(address(0), 2 ether);
    }

    function test_FailsIfInsufficientBalance() public {
        vm.prank(address(owner));
        vm.expectRevert("Treasury: Insufficient Balance");
        treasury.withdrawFundsAsPsyDao(address(owner), 12 ether);
    }

    function test_FailsIfWithdrawingNothing() public {
        vm.prank(address(owner));
        vm.expectRevert("Treasury: Cannot Withdraw Zero");
        treasury.withdrawFundsAsPsyDao(address(owner), 0);
    }

    function test_WithdrawsToReceiver() public {
        uint256 ownerBalance = address(owner).balance;
        
        assertEq(address(treasury).balance, 5 ether);

        vm.prank(owner);
        treasury.withdrawFundsAsPsyDao(address(owner), 2 ether);
        assertEq(address(owner).balance, ownerBalance + 2 ether);
        assertEq(address(treasury).balance, 3 ether);
    }

    
}
