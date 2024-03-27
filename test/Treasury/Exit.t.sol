// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract ExitTest is TestSetup {

    function setUp() public {
        setUpTests();

        vm.startPrank(owner);
        core.mintInitialBatch();
        core.enableRageQuit();
        vm.stopPrank();

        uint256[] memory tokensForAlice = new uint256[](3);
        tokensForAlice[0] = 0;
        tokensForAlice[1] = 2;
        tokensForAlice[2] = 3;

        transferNftToUser(address(alice), tokensForAlice);

        vm.deal(address(alice), 10 ether);
        vm.prank(alice);
        (bool sent, ) = address(treasury).call{value: 5 ether}("");
    }

    function test_FailsIfUserIsNotTokenOwner() public {
        vm.prank(address(core));
        vm.expectRevert("Treasury: Not token owner");
        treasury.exit(0, address(owner));
    }

    function test_FailsIfCallerIsNotCoreContract() public {
        vm.prank(owner);
        vm.expectRevert("Treasury: Only callable by Core.sol");
        treasury.exit(0, address(alice));
    }

    function test_RageQuitWorksPerfectly() public {

        assertEq(address(treasury).balance, 5 ether);
        assertEq(psyNFT.tokenId(), 5);
        uint256 aliceBalance = address(alice).balance;

        assertEq(psyNFT.ownerOf(0), address(alice));
        uint256 treasuryPortion = treasury.ethBalance() / psyNFT.tokenId();

        vm.prank(address(core));
        treasury.exit(0, address(alice));

        assertEq(treasury.userBalances(address(alice)), treasuryPortion);
    }
}
