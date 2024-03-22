// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/PsyNFT.sol";
import "../src/NFTSublicences.sol";
import "../src/Auction.sol";
import "../src/Core.sol";
import "../src/Treasury.sol";
import "../src/TokenSale.sol";
import "./TestPsyToken.sol";

contract TestSetup is Test {

    error OwnableUnauthorizedAccount(address account);
    error ERC721NonexistentToken(uint256 tokenId);
    error ERC721IncorrectOwner(address from, uint256 tokenId, address previousOwner);

    event Transfer(address from, address to, uint256 tokenId);

    PsyNFT public psyNFT;
    NFTSublicences public sublicencesNft;
    Auction public auction;
    Core public core;
    Treasury public treasury;
    TokenSale public tokenSale;
    TestPsyToken public psyToken;

    address owner = vm.addr(1);
    address alice = vm.addr(2);
    address bob = vm.addr(3);
    address robyn = vm.addr(4);

    uint256 ONE_DAY = 86400;

    function setUpTests() public {
        vm.startPrank(owner);
        psyNFT = new PsyNFT();
        sublicencesNft = new NFTSublicences(address(psyNFT));
        auction = new Auction();
        treasury = new Treasury(address(psyNFT));
        core = new Core(address(psyNFT), address(sublicencesNft), address(auction), address(treasury));
        psyToken = new TestPsyToken("TestPsy", "PSY");
        tokenSale = new TokenSale(address(psyToken), 0.1 ether);
        psyNFT.setCoreContract(address(core));
        sublicencesNft.setCoreContract(address(core));
        psyNFT.setTreasury(address(treasury));
        treasury.setCoreContract(address(core));
        vm.stopPrank();
    }
    
    function transferNftToUser(address _user, uint256[] memory _tokens) public {
        vm.prank(address(core));
        psyNFT.transferNFTs(_tokens, _user);
    }
}
