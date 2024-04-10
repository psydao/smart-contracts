// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract KickTest is TestSetup {

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

    function test_FailsIfCallerIsNotContractOwner() public {
        vm.prank(address(alice));
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        core.kick(0, address(alice));
    }

    function test_KickWorks() public {
        vm.deal(address(alice), 10 ether);
        vm.prank(alice);
        (bool sent, ) = address(treasury).call{value: 5 ether}("");

        assertEq(address(treasury).balance, 5 ether);
        assertEq(psyNFT.tokenId(), 3);
        uint256 aliceBalance = address(alice).balance;

        assertEq(psyNFT.ownerOf(0), address(alice));
        uint256 treasuryPortion = treasury.ethBalance() / psyNFT.tokenId();

        vm.prank(address(owner));
        core.kick(0, address(alice));

        assertEq(treasury.userBalances(address(alice)), treasuryPortion);
    }
}
