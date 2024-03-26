// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract UpdateChainlinkPriceFeedTest is TestSetup {

    //Sepolia price feed
    address newPriceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    function setUp() public {
        setUpTests();
    }

    function test_FailsIfNotOwner() public {
        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(alice)));
        tokenSale.updateChainlinkPriceFeed(newPriceFeed);
    }

    function test_FailsIfPriceFeedIsAddressZero() public {
        vm.startPrank(owner);
        vm.expectRevert("TokenSale: Cannot Be Address 0");
        tokenSale.updateChainlinkPriceFeed(address(0));
    }

    function test_UpdatesPriceFeedAddress() public {
        psyToken.mint(address(tokenSale), 10e18);

        assertEq(address(tokenSale.dataFeed()), 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        vm.startPrank(owner);
        tokenSale.updateChainlinkPriceFeed(newPriceFeed);
        assertEq(address(tokenSale.dataFeed()), newPriceFeed);
    }
}
