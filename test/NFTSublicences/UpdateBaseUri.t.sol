// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract UpdateBaseUriTest is TestSetup {

    string newUri = "ipfs://0x38b838b34b";

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfCallerIsNotContractOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        sublicencesNft.updateBaseUri(newUri);
    }

    function test_SetsNewBaseUri() public {
        assertEq(sublicencesNft.uri(2), "");
        vm.prank(owner);
        sublicencesNft.updateBaseUri(newUri);
        assertEq(sublicencesNft.uri(2), newUri);
    }
}