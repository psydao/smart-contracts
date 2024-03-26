// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./PsyNFT.sol";
import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "forge-std/console.sol";

contract Treasury is Ownable2Step, ReentrancyGuard {

    PsyNFT public psyNFT;

    uint256 public balanceOfContract;
    address public core;

    mapping(address => uint256) public userBalances;

    constructor(address _psyNFT) Ownable(msg.sender) {
        psyNFT = PsyNFT(_psyNFT);
    }

    function exit(uint256 _tokenId, address _user) external nonReentrant {
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

    function withdrawUserFunds() external {
        require(userBalances[msg.sender] > 0, "Treasury: User Insufficient Balance");
        
        uint256 amountToSend = userBalances[msg.sender];
        userBalances[msg.sender] = 0;

        (bool sent,) = msg.sender.call{value: amountToSend}("");
        require(sent, "Failed to send Ether");
    }

    function withdrawFundsAsPsyDao(address _receiver, uint256 _amount) external onlyOwner {
        require(_receiver != address(0), "Treasury: Receiver Cannot Be Zero Address");
        require(address(this).balance >= _amount, "Treasury: Insufficient Balance");
        
        (bool sent,) = _receiver.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function _calculateProRataPayout() internal returns (uint256){
        uint256 currentSupply = psyNFT.tokenId() - psyNFT.totalTokensBurnt();
        return balanceOfContract /  currentSupply; 
    }

    receive() external payable {
        balanceOfContract += msg.value;
    }
    
}
