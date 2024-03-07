// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import "forge-std/console.sol";

contract PsyNFT is ERC721, Ownable2Step {

    uint256 public tokenId;
    uint256 public secondLastFibonacci;
    uint256 public previousFibonacci;

    bool public initialMintCalled;

    constructor() ERC721("PsyNFT", "PSY") Ownable(msg.sender) {

    }

    /// @notice Mints the initial 5 NFT's for the founding members
    /// @dev This is a unique function to begin the DAO and should only be called once
    function initialMint() external onlyOwner {
        require(!initialMintCalled, "Initial mint completed");
        uint256 localTokenId = 0;

        for(localTokenId; localTokenId < 5; localTokenId++) {
            _mint(address(this), localTokenId);
        }

        tokenId = localTokenId;
        secondLastFibonacci = 1;
        previousFibonacci = 2;
        initialMintCalled = true;
    }
    
    /// @notice Mints new NFT's following the fibonacci sequence
    /// @dev Each batch amount follows the fibonacci sequence
    function mintBatchInFibonacci() external onlyOwner {
        uint256 batchAmount = secondLastFibonacci + previousFibonacci;
        uint256 localTokenId = tokenId;

        for(uint256 x; x < batchAmount; x++) {
            _safeMint(address(this), localTokenId);
            localTokenId++;
        }

        tokenId = localTokenId;

        secondLastFibonacci = previousFibonacci;
        previousFibonacci = batchAmount;
    }

    function transferAllToAuction() external onlyOwner {
        
    }

    /// @notice Allows contract to receive NFTs
    /// @dev Returns the valid selector to the ERC721 contract to prove contract can hold NFTs
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
