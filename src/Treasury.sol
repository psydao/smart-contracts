// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./PsyNFT.sol";
import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "forge-std/console.sol";

contract Treasury is Ownable2Step, ReentrancyGuard {
    PsyNFT public psyNFT;

    uint256 public ethBalance;
    address public core;

    mapping(address => uint256) public userBalances;

    constructor(address _psyNFT) Ownable(msg.sender) isZeroAddress(_psyNFT) {
        psyNFT = PsyNFT(_psyNFT);
    }

    /**
     * @notice Allows a user to exit by burning their token and receiving a payout.
     * @dev The user must be the owner of the token and the function can only be called by the Core contract.
     * @param _tokenId The ID of the token to be burned.
     * @param _user The address of the user who owns the token.
     */
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
    function setCoreContract(address _core) external onlyOwner isZeroAddress(_core) {
        core = _core;
    }

    /**
     * @notice Allows a user to withdraw their funds from the Treasury contract.
     * @dev The user must have a positive balance in the Treasury contract.
     * @dev The function can only be called by the user.
     * @dev The user's balance will be set to zero after the withdrawal.
     * @dev The amount to send must be available in the Treasury contract's balance.
     */
    function withdrawUserFunds() external nonReentrant {
        require(userBalances[msg.sender] > 0, "Treasury: User Insufficient Balance");

        uint256 amountToSend = userBalances[msg.sender];
        require(address(this).balance >= amountToSend, "Treasury: Insufficient Balance");

        userBalances[msg.sender] = 0;

        (bool sent,) = msg.sender.call{value: amountToSend}("");
        require(sent, "Failed to send Ether");
    }

    /**
     * @notice Withdraws funds from the Treasury contract and sends them to the specified receiver address.
     * @dev Only the contract owner can call this function.
     * @dev The amount to withdraw must be available in the Treasury contract's balance.
     * @param _receiver The address to which the funds will be sent.
     * @param _amount The amount of funds to withdraw.
     */
    function withdrawFundsAsPsyDao(address _receiver, uint256 _amount)
        external
        isZeroAddress(_receiver)
        onlyOwner
        nonReentrant
    {
        require(address(this).balance >= _amount, "Treasury: Insufficient Balance");
        require(_amount > 0, "Treasury: Cannot Withdraw Zero");

        (bool sent,) = _receiver.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function _calculateProRataPayout() internal returns (uint256) {
        uint256 currentSupply = psyNFT.tokenId() - psyNFT.totalTokensBurnt();
        return ethBalance / currentSupply;
    }

    receive() external payable {
        ethBalance += msg.value;
    }

    modifier isZeroAddress(address _address) {
        require(_address != address(0), "Treasury: Cannot Be Zero Address");
        _;
    }
}
