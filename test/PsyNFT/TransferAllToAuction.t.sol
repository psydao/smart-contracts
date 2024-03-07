// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";
import "../../src/PsyNFT.sol";


contract TransferAllToAuctionTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_TransferAllToAuctionFailsIfNotOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        psyNFT.transferAllToAuction();
    }
}
