// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract UnlockTokenTest is TestSetup {

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfNotOwner() public {
        vm.startPrank(owner);
        tokenSale.pauseSale();

        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        tokenSale.unlockToken();
    }

    function test_FailsIfTokenAlreadyUnlocked() public {
        vm.startPrank(owner);
        tokenSale.unlockToken();

        vm.expectRevert("TokenSale: Tokens Already Unlocked");
        tokenSale.unlockToken();
    }

    function test_TokensUnLock() public {
        assertEq(tokenSale.tokensLocked(), true);
        vm.startPrank(owner);
        tokenSale.pauseSale();
        tokenSale.unlockToken();
        assertEq(tokenSale.tokensLocked(), false);
    }
}
