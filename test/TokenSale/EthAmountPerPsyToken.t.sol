// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract EthAmountPerPsyTokenTest is TestSetup {

    uint256 mainnetFork;
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");


    function setUp() public {
        setupFork();
        setUpTests();
    }

    function test_ReturnsEthPricePerToken() public {
        uint256 tokenPriceInEth = tokenSale.ethAmountPerPsyToken();
        console.log("Psy price in ETH at block 11_493_383 was: ", tokenPriceInEth);
    }

    function setupFork() public {
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(mainnetFork);
        vm.rollFork(11_493_383);
    }
}
