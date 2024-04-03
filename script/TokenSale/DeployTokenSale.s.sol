// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../src/TokenSale.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DeployTokenSale is Script {
    using Strings for string;

    /*---- Storage variables ----*/

    TokenSale public tokenSale;
    address chainlinkMainnetPriceFeed = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address chainlinkSepoliaPriceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    uint256 originalTokenPrice = 0.1 ether;
    

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy TokenSale.sol
        tokenSale = new TokenSale(vm.envAddress("PSYNFT_CONTRACT"), chainlinkSepoliaPriceFeed, originalTokenPrice);

        console.log("Token Sale Address: ", address(tokenSale));
    }
}