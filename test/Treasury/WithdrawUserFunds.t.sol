// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract WithdrawUserFundsTest is TestSetup {

    function setUp() public {
        setUpTests();

        vm.prank(owner);
        core.mintInitialBatch();

        uint256[] memory tokensForAlice = new uint256[](3);
        tokensForAlice[0] = 0;
        tokensForAlice[1] = 1;
        tokensForAlice[2] = 2;

        transferNftToUser(address(alice), tokensForAlice);
    }

    function test_FailsIfUserHasInsufficientBalance() public {
        setUpContractWithEth();

        vm.prank(address(alice));
        vm.expectRevert("Treasury: User Insufficient Balance");
        treasury.withdrawUserFunds();
    }

    function test_FailsIfContractHasInsufficientBalance() public {
        setUpContractWithEth();
        
        vm.prank(address(core));
        treasury.exit(2, address(alice));

        vm.prank(owner);
        treasury.withdrawFundsAsPsyDao(address(owner), 3 ether);

        vm.prank(address(alice));
        vm.expectRevert("Treasury: Insufficient Balance");
        treasury.withdrawUserFunds();
    }

    function test_WithdrawsUserFunds() public {
        setUpContractWithEth();

        uint256 aliceBalance = address(alice).balance;
        assertEq(treasury.userBalances(address(alice)), 0);

        vm.prank(address(core));
        treasury.exit(2, address(alice));

        assertEq(treasury.userBalances(address(alice)), 1 ether);

        vm.prank(alice);
        treasury.withdrawUserFunds();
        
        assertEq(address(alice).balance, aliceBalance + 1 ether);
        assertEq(address(treasury).balance, 2 ether);
        assertEq(treasury.userBalances(address(alice)), 0);
    }

    function setUpContractWithEth() public {
        vm.deal(address(alice), 10 ether);
        vm.prank(alice);
        (bool sent, ) = address(treasury).call{value: 3 ether}("");
    }
}
