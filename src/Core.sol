// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import "./PsyNFT.sol";
import "./Auction.sol";
import "./Treasury.sol";

contract Core is Ownable2Step {

    PsyNFT public psyNFT;
    Treasury public treasury;
    address public auctionContract;
    bool public rageQuitAllowed;

    mapping(uint256 => address) public batchToAuctionAddress;

    constructor(
        address _psyNFT,
        address _auction,
        address _treasury
    ) Ownable(msg.sender) {
        require(_psyNFT != address(0), "Cannot be address 0");
        require(_auction != address(0), "Cannot be address 0");
        require(_treasury != address(0), "Cannot be address 0");

        psyNFT = PsyNFT(_psyNFT);
        treasury = Treasury(payable(_treasury));
        auctionContract = _auction;
    }

    function mintNextBatch() external onlyOwner {
        psyNFT.batchMintInFibonacci();
    }

    function transferNftsToAuction(uint256[] memory _tokenIds) external onlyOwner {
        _transfer(_tokenIds, auctionContract);
    }

    function transferNftsToUser(uint256[] memory _tokenIds, address _user) external onlyOwner {
        _transfer(_tokenIds, _user);
    }

    function enableRageQuit() external onlyOwner {
        require(!rageQuitAllowed, "Treasury: Rage Quit Already Enabled");
        rageQuitAllowed = true;
    }

    function disableRageQuit() external onlyOwner {
        require(rageQuitAllowed, "Treasury: Rage Quit Already Disabled");
        rageQuitAllowed = false;
    }

    function rageQuit(uint256 _tokenId) external {
        require(rageQuitAllowed, "Treasury: Rage Quit Disabled");
        treasury.exit(_tokenId, msg.sender);
    }

    function kick(uint256 _tokenId, address _user) external onlyOwner {
        treasury.exit(_tokenId, _user);
    }

    function _transfer(uint256[] memory _tokenIds, address _user) internal {
        psyNFT.transferNFTs(_tokenIds, _user);
    }
    
    

}
