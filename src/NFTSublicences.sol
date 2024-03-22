// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PsyNFT.sol";

contract NFTSublicences is ERC1155, Ownable {
    PsyNFT public psyNFT;

    address public core;

    mapping(uint256 => uint256) public psyNftSublicenseSupply;

    constructor(address _psyNft) ERC1155("") Ownable(msg.sender) {
        psyNFT = PsyNFT(_psyNft);
    }

    function setURI(string memory newuri) public {
        _setURI(newuri);
    }

    /**
     * @notice Sets the address of the Core contract.
     * @dev Only the contract owner can call this function.
     * @param _core The address of the Core contract.
     * @dev The address cannot be the zero address.
     */
    function setCoreContract(address _core) external onlyOwner {
        require(_core != address(0), "NFTSublicences: Cannot Be Address 0");
        core = _core;
    }

    function mintSublicences(address _minter, uint256 _erc721TokenId, uint256 _supply) external onlyCoreContract {
        require(_minter == psyNFT.ownerOf(_erc721TokenId), "Core: Not Token Holder");
        _mint(_minter, _erc721TokenId, _supply, "");
    }

    modifier onlyCoreContract() {
        require(msg.sender == core, "NFTSublicences: Caller Not Core Contract");
        _;
    }
    
}
