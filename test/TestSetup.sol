// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/PsyNFT.sol";

contract TestSetup is Test {

    error OwnableUnauthorizedAccount(address account);

    PsyNFT public psyNFT;

    address owner = vm.addr(1);
    address alice = vm.addr(2);
    address bob = vm.addr(3);

    function setUpTests() public {
        vm.startPrank(owner);
        psyNFT = new PsyNFT();
        vm.stopPrank();
    }
}
