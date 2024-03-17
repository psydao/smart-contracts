// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "forge-std/console.sol";

contract PsyNFT is ERC721, Ownable2Step, ReentrancyGuard {
    
    struct ApprovedTransfers {
        uint256 tokenId;
        address to;
        uint256 transferExpiryDate;
    }

    uint256 public tokenId;
    uint256 public previousFibonacci;
    uint256 public totalTokensBurnt;

    address public core;
    address public treasury;

    bool public initialMintCalled;
    bool public controlledTransfers;

    mapping(uint256 => ApprovedTransfers) public approvedTransfers;

    constructor() ERC721("PsyNFT", "PSY") Ownable(msg.sender) {
        controlledTransfers = true;
    }

    /**
     * @notice Initializes the contract by minting the initial tokens.
     * @dev Only the contract owner can call this function.
     * @dev This function can only be called once.
     */
    function initialMint() external onlyOwner nonReentrant {
        require(!initialMintCalled, "Initial mint completed");
        
        initialMintCalled = true;
        previousFibonacci = 3;

        uint256 localTokenId = 0;

        while (localTokenId < 5) {
            _safeMint(address(this), localTokenId);
            localTokenId++;
        }

        tokenId = localTokenId;
    }

    /**
     * @notice Batch mints a specified number of tokens in a Fibonacci sequence.
     * @dev Only the contract owner can call this function.
     * @dev Requires that the initial mint has been completed.
     * @dev The number of tokens to be minted is determined by the previous Fibonacci number.
     */
    function batchMintInFibonacci() external onlyCoreContract nonReentrant {
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
    function transferNFTs(uint256[] memory _tokenIds, address _recipient) external onlyCoreContract {
        require(_recipient != address(0), "Cannot be address 0");
        require(_tokenIds.length != 0, "No tokens to transfer");
        for (uint256 x; x < _tokenIds.length; x++) {
            _safeTransfer(address(this), _recipient, _tokenIds[x]);
        }
    }

    function approvePsyNftTransfer(
        uint256 _tokenId, 
        address _to, 
        uint256 _allowedTransferTimeInSeconds
    ) external onlyOwner {
        require(_tokenId < tokenId, "PsyNFT: Non Existent Token");
        require(block.timestamp > approvedTransfers[_tokenId].transferExpiryDate, "PsyNFT: Transfer Request Currently Active");
        require(_to != address(0), "PsyNFT: Cannot Approve Address Zero As Recipient");
        
        approvedTransfers[_tokenId] = ApprovedTransfers({
            tokenId: _tokenId,
            to: _to, 
            transferExpiryDate: block.timestamp + _allowedTransferTimeInSeconds
        });
    }

    /**
     * @notice Sets the address of the Core contract.
     * @dev Only the contract owner can call this function.
     * @param _core The address of the Core contract.
     * @dev The address cannot be the zero address.
     */
    function setCoreContract(address _core) external onlyOwner {
        require(_core != address(0), "Cannot be address 0");
        core = _core;
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Cannot be address 0");
        treasury = _treasury;
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
        if (
            controlledTransfers && 
            ownerOf(_tokenId) != address(this) && 
            _to != address(treasury)
        ) {
            require(_to == approvedTransfers[_tokenId].to, "PsyNFT: Incorrect Receiver");
            require(block.timestamp <= approvedTransfers[_tokenId].transferExpiryDate, "PsyNFT: Approval Expired");
        }

        return super.transferFrom(_from, _to, _tokenId);
    }

    function burn(uint256 _tokenId) external {
        totalTokensBurnt++;
        _burn(_tokenId);
    } 

    /// @notice Allows contract to receive NFTs
    /// @dev Returns the valid selector to the ERC721 contract to prove contract can hold NFTs
    function onERC721Received(address, address, uint256 _tokenId, bytes calldata) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    modifier onlyCoreContract() {
        require(msg.sender == address(core), "Only callable by Core.sol");
        _;
    }
}
