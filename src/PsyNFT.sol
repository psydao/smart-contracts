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

    constructor() ERC721("PsyNFT", "PSY") Ownable(msg.sender) {}

    /**
     * @notice Initializes the contract by minting the initial tokens.
     * @dev Only the contract owner can call this function.
     * @dev This function can only be called once.
     */
    function initialMint() external onlyOwner {
        require(!initialMintCalled, "Initial mint completed");
        initialMintCalled = true;

        uint256 localTokenId = 0;

        while (localTokenId < 5) {
            _safeMint(address(this), localTokenId);
            localTokenId++;
        }

        tokenId = localTokenId;
        previousFibonacci = 3;
    }

    /**
     * @notice Batch mints a specified number of tokens in a Fibonacci sequence.
     * @dev Only the contract owner can call this function.
     * @dev Requires that the initial mint has been completed.
     * @dev The number of tokens to be minted is determined by the previous Fibonacci number.
     */
    function batchMintInFibonacci() external onlyOwner {
        require(initialMintCalled, "Initial mint not completed");

        uint256 batchAmount = previousFibonacci;
        previousFibonacci = tokenId;

        while (batchAmount > 0) {
            _safeMint(address(this), tokenId);
            tokenId++;
            batchAmount--;
        }
    }
    /**
     * @notice Transfers multiple NFTs to a specified recipient.
     * @dev Only the contract owner can call this function.
     * @param _tokenIds An array of token IDs to be transferred.
     * @param _recipient The address of the recipient.
     */

    function transferNFTs(uint256[] memory _tokenIds, address _recipient) external onlyOwner {
        require(_recipient != address(0), "Cannot be address 0");
        require(_tokenIds.length != 0, "No tokens to transfer");
        for (uint256 x; x < _tokenIds.length; x++) {
            _safeTransfer(address(this), _recipient, _tokenIds[x]);
        }
    }

    /**
     * @notice Submits a transfer request for a specific token to a given recipient.
     * @dev The caller must be the owner of the token.
     * @param _to The address of the recipient.
     * @param _tokenId The ID of the token to be transferred.
     */
    function submitTransferRequest(address _to, uint256 _tokenId) external {
        require(_tokenId < tokenId, "Non existent token");
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
    /**
     * @notice Finalizes a transfer request for a specific token.
     * @dev Only the contract owner can call this function.
     * @param _tokenId The ID of the token for which the transfer request is being finalized.
     * @param _decision The decision on whether to approve or reject the transfer request.
     * @dev The token must exist and the transfer request must be active and not expired.
     */

    function finalizeRequest(uint256 _tokenId, bool _decision) external onlyOwner {
        require(_tokenId < tokenId, "Non existent token");
        TransferRequest storage request = transferRequests[_tokenId];
        require(request.requestEndTime != 0, "Request non existent");
        require(block.timestamp <= request.requestEndTime, "Request expired");

        request.approved = _decision;
    }
    /**
     * @notice Sets the transfer window period for transfer requests.
     * @dev Only the contract owner can call this function.
     * @param _transferPeriod The duration of the transfer window period in seconds.
     */

    function setTransferWindowPeriod(uint256 _transferPeriod) external onlyOwner {
        transferWindowPeriod = _transferPeriod;
    }
    
    /**
     * @notice Transfers an NFT from one address to another.
     * @dev Overrides the transferFrom function in the ERC721 contract.
     * @param _from The address from which the NFT is being transferred.
     * @param _to The address to which the NFT is being transferred.
     * @param _tokenId The ID of the NFT being transferred.
     * @dev If the NFT is not owned by the contract, the transfer must be approved by the transfer request.
     * @dev The recipient address must match the address specified in the transfer request.
     * @dev The transfer request must not be expired.
     */
    function transferFrom(address _from, address _to, uint256 _tokenId) public override {
        if (ownerOf(_tokenId) != address(this)) {
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
