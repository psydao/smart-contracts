// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import "forge-std/console.sol";

contract PsyNFT is ERC721, Ownable2Step {
    struct TransferRequest {
        uint256 tokenId;
        uint256 requestEndTime;
        address from;
        address to;
        bool approved;
    }

    uint256 public tokenId;
    uint256 public secondLastFibonacci;
    uint256 public previousFibonacci;
    uint256 public transferWindowPeriod;

    bool public initialMintCalled;

    mapping(uint256 => TransferRequest) public transferRequests;

    constructor() ERC721("PsyNFT", "PSY") Ownable(msg.sender) {

    }

    /// @notice Mints the initial 5 NFT's for the founding members
    /// @dev This is a unique function to begin the DAO and should only be called once
    function initialMint() external onlyOwner {
        require(!initialMintCalled, "Initial mint completed");
        uint256 localTokenId = 0;

        for(localTokenId; localTokenId < 5; localTokenId++) {
            _safeMint(address(this), localTokenId);
        }

        tokenId = localTokenId;
        secondLastFibonacci = 1;
        previousFibonacci = 2;
        initialMintCalled = true;
    }
    
    /// @notice Mints new NFT's following the fibonacci sequence
    /// @dev Each batch amount follows the fibonacci sequence
    function batchMintInFibonacci() external onlyOwner {
        require(initialMintCalled, "Initial mint not completed");
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


    function transferNFTs(
        uint256[] memory _tokenIds, 
        address _recipient
    ) external onlyOwner {
        require(_recipient != address(0), "Cannot be address 0");
        for(uint256 x; x < _tokenIds.length; x++) {
            _safeTransfer(address(this), _recipient, _tokenIds[x]);
        }
    }

    function submitTransferRequest(
        address _to, 
        uint256 _tokenId
    ) external {
        require(msg.sender == ownerOf(_tokenId), "Not token owner");
        require(block.timestamp > transferRequests[_tokenId].requestEndTime, "Transfer request currently active");
        require(_to != address(0), "Cannot be address 0");
        
        transferRequests[_tokenId] = TransferRequest({
            tokenId: _tokenId,
            requestEndTime: block.timestamp + transferWindowPeriod,
            from: msg.sender,
            to: _to,
            approved: false
        });
    }

    function finalizeRequest(uint256 _tokenId, bool _decision) external onlyOwner {
        TransferRequest storage request = transferRequests[_tokenId];
        require(request.requestEndTime != 0, "Request non existent");
        require(block.timestamp <= request.requestEndTime, "Request expired");

        request.approved = _decision;
    }

    function setTransferWindowPeriod(uint256 _transferPeriod) external onlyOwner {
        transferWindowPeriod = _transferPeriod;
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public override {
        if(ownerOf(_tokenId) != address(this)) {
            require(transferRequests[_tokenId].approved, "Transfer of token not approved");
            require(_to == transferRequests[_tokenId].to, "Different receivers");
            require(block.timestamp <= transferRequests[_tokenId].requestEndTime, "Request expired");
        }

        return super.transferFrom(_from, _to, _tokenId);
    } 

    /// @notice Allows contract to receive NFTs
    /// @dev Returns the valid selector to the ERC721 contract to prove contract can hold NFTs
    function onERC721Received(address, address, uint256 _tokenId, bytes calldata) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
