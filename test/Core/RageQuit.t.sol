// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract RageQuitTest is TestSetup {

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
    }

    function test_FailsIfRageQuitIsDisabled() public {
        vm.prank(owner);
        core.disableRageQuit();
        
        vm.prank(address(alice));
        vm.expectRevert("Treasury: Rage Quit Disabled");
        core.rageQuit(0);
    }

    function test_RageQuitWorks() public {
        vm.deal(address(alice), 10 ether);
        vm.prank(alice);
        (bool sent, ) = address(treasury).call{value: 5 ether}("");

        assertEq(address(treasury).balance, 5 ether);
        assertEq(psyNFT.tokenId(), 5);
        uint256 aliceBalance = address(alice).balance;

        assertEq(psyNFT.ownerOf(0), address(alice));
        uint256 treasuryPortion = treasury.balanceOfContract() / psyNFT.tokenId();

        vm.prank(address(alice));
        core.rageQuit(0);

        assertEq(treasury.userBalances(address(alice)), treasuryPortion);
    }
}
