// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract SetTransferWindowPeriodTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfCallerIsNotContractOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        psyNFT.setTransferWindowPeriod(86402);
    }

    function test_SetsTransferWindowCorrectly() public {
        assertEq(psyNFT.transferWindowPeriod(), 86400);
        vm.prank(owner);
        psyNFT.setTransferWindowPeriod(86402);
        assertEq(psyNFT.transferWindowPeriod(), 86402);
    }
}
