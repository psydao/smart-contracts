// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PsyNFT.sol";

contract NFTSublicences is ERC1155, Ownable {
    PsyNFT public psyNFT;

    address public core;

    mapping(uint256 => uint256) public psyNftSublicenseSupply;

    constructor(address _psyNft, string memory _initUri) ERC1155(_initUri) Ownable(msg.sender) {
        psyNFT = PsyNFT(_psyNft);
    }

    /**
     * @notice Sets the address of the Core contract.
     * @dev Only the contract owner can call this function.
     * @param _core The address of the Core contract.
     * @dev The address cannot be the zero address.
     */
    function setCoreContract(address _core) external onlyOwner {
        require(_core != address(0), "NFTSublicences: Cannot Be Zero Address");
        core = _core;
    }

    /**
     * @notice Mints a specified amount of sublicenses for a given ERC721 token.
     * @dev Only the Core contract can call this function.
     * @param _minter The address of the minter who will receive the sublicenses.
     * @param _erc721TokenId The ID of the ERC721 token for which sublicenses are being minted.
     * @param _supply The amount of sublicenses to mint.
     * @dev The minter must be the owner of the ERC721 token.
     */
    function mint(address _minter, uint256 _erc721TokenId, uint256 _supply) external onlyCoreContract {
        require(_minter == psyNFT.ownerOf(_erc721TokenId), "NFTSublicences: Not Token Holder");
        _mint(_minter, _erc721TokenId, _supply, "");
    }

    /**
     * @notice Updates the base URI for the ERC1155 token metadata.
     * @dev Only the contract owner can call this function.
     * @param _newuri The new base URI to set for the token metadata.
     */
    function updateBaseUri(string memory _newuri) external onlyOwner {
        _setURI(_newuri);
    }

    modifier onlyCoreContract() {
        require(msg.sender == core, "NFTSublicences: Caller Not Core Contract");
        _;
    }
}
