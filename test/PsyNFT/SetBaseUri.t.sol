// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract SetBaseUriTest is TestSetup {

    string newUri = "ipfs://0x38b838b34b";

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfCallerIsNotContractOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        psyNFT.setBaseUri(newUri);
    }

    function test_SetsNewBaseUri() public {
        assertEq(psyNFT.baseUri(), "");
        vm.prank(owner);
        psyNFT.setBaseUri(newUri);
        assertEq(psyNFT.baseUri(), "ipfs://0x38b838b34b");
    }
}
