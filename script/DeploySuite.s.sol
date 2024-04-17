// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Treasury.sol";
import "../src/Core.sol";
import "../src/NFTSublicences.sol";
import "../src/PsyNFT.sol";
import "../src/TokenSale.sol";
import "../src/Auction.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../test/TestPsyToken.sol";

contract DeploySuite is Script {
    using Strings for string;

    /*---- Storage variables ----*/

    TestPsyToken public psyToken;
    Auction public auction;
    Treasury public treasury;
    Core public core;
    NFTSublicences public nftSublicences;
    PsyNFT public psyNft;
    TokenSale public tokenSale;
    address chainlinkMainnetPriceFeed = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address chainlinkSepoliaPriceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    uint256 originalTokenPrice = 0.1 ether;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy contracts
        psyNft = new PsyNFT();
        nftSublicences = new NFTSublicences(address(psyNft), "");
        treasury = new Treasury(address(psyNft));
        core = new Core(address(psyNft), address(nftSublicences), address(treasury));
        tokenSale = new TokenSale("0x2196B84EaCe74867b73fb003AfF93C11FcE1D47A", chainlinkMainnetPriceFeed, originalTokenPrice);

        //Setup functions
        psyNft.setCoreContract(address(core));
        nftSublicences.setCoreContract(address(core));
        psyNft.setTreasury(address(treasury));
        treasury.setCoreContract(address(core));

        console.log("PsyNFT Address: ", address(psyNft));
        console.log("ERC1155 Address: ", address(nftSublicences));
        console.log("Treasury Address: ", address(treasury));
        console.log("Core Address: ", address(core));
        console.log("Token Sale Address: ", address(tokenSale));
    }
}