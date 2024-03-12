// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/PsyNFT.sol";
import "../src/Auction.sol";
import "../src/Core.sol";
import "../src/Treasury.sol";

contract TestSetup is Test {

    error OwnableUnauthorizedAccount(address account);
    error ERC721NonexistentToken(uint256 tokenId);
    error ERC721IncorrectOwner(address from, uint256 tokenId, address previousOwner);

    event Transfer(address from, address to, uint256 tokenId);

    PsyNFT public psyNFT;
    Auction public auction;
    Core public core;
    Treasury public treasury;

    address owner = vm.addr(1);
    address alice = vm.addr(2);
    address bob = vm.addr(3);

    uint256 ONE_DAY = 86400;

    function setUpTests() public {
        vm.startPrank(owner);
        psyNFT = new PsyNFT();
        auction = new Auction();
        treasury = new Treasury(address(psyNFT));
        core = new Core(address(psyNFT), address(auction), address(treasury));
        psyNFT.setTransferWindowPeriod(ONE_DAY);
        psyNFT.setCoreContract(address(core));
        psyNFT.setTreasury(address(treasury));
        treasury.setCoreContract(address(core));
        vm.stopPrank();
    }
}
