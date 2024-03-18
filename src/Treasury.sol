// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./PsyNFT.sol";
import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import "forge-std/console.sol";

contract Treasury is Ownable2Step {

    PsyNFT public psyNFT;

    uint256 public balanceOfContract;
    address public core;

    mapping(address => uint256) public userBalances;

    constructor(address _psyNFT) Ownable(msg.sender) {
        psyNFT = PsyNFT(_psyNFT);
    }

    function exit(uint256 _tokenId, address _user) external {
        require(_user == psyNFT.ownerOf(_tokenId), "Treasury: Not token owner");
        require(msg.sender == core, "Treasury: Only callable by Core.sol");
        
        uint256 payout = _calculateProRataPayout();
        userBalances[_user] += payout;

        psyNFT.burn(_tokenId);
    }

    /**
     * @notice Sets the address of the Core contract.
     * @dev Only the contract owner can call this function.
     * @param _core The address of the Core contract.
     * @dev The address cannot be the zero address.
     */
    function setCoreContract(address _core) external onlyOwner {
        require(_core != address(0), "Treasury: Core Cannot Be Zero Address");
        core = _core;
    }

    function _calculateProRataPayout() internal returns (uint256){
        uint256 currentSupply = psyNFT.tokenId() - psyNFT.totalTokensBurnt();
        return balanceOfContract /  currentSupply; 
    }

    /// @notice Allows contract to receive NFTs
    /// @dev Returns the valid selector to the ERC721 contract to prove contract can hold NFTs
    function onERC721Received(address, address, uint256 _tokenId, bytes calldata) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {
        balanceOfContract += msg.value;
    }
    
}
