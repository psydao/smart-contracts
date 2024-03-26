// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../TestSetup.sol";

contract BurnTest is TestSetup {
    
    uint256[] public tokens = new uint256[](3);

    function setUp() public {
        setUpTests();
        vm.prank(owner);
        core.mintInitialBatch();

        tokens[0] = 0;
        tokens[1] = 2;
        tokens[2] = 3;
    }

    function test_BurnNftFailsIfCallerIsNotTreasury() public {
        transferNftToUser(address(alice), tokens);   

        vm.prank(address(owner));
        vm.expectRevert("PsyNFT: Caller Is Not Treasury");
        psyNFT.burn(2);
    }

    function test_BurnNft() public {
        transferNftToUser(address(alice), tokens);   

        assertEq(psyNFT.totalTokensBurnt(), 0);     
        assertEq(psyNFT.ownerOf(2), address(alice));     

        vm.prank(address(treasury));
        psyNFT.burn(2);

        assertEq(psyNFT.totalTokensBurnt(), 1);
    }
}
