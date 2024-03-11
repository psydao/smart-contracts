// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import "./PsyNFT.sol";
import "./Auction.sol";

contract Core is Ownable2Step {

    PsyNFT public psyNFT;
    
    address public auctionContract;

    mapping(uint256 => address) public batchToAuctionAddress;

    constructor(
        address _psyNFT,
        address _auction
    ) Ownable(msg.sender) {
        require(_psyNFT != address(0), "Cannot be address 0");
        require(_auction != address(0), "Cannot be address 0");

        psyNFT = PsyNFT(_psyNFT);
        auctionContract = _auction;
    }

    function mintNextBatch() external onlyOwner {
        psyNFT.batchMintInFibonacci();
    }

    function transferNftToAuction(uint256[] memory _tokenIds) external onlyOwner {
        _transfer(_tokenIds, auctionContract);
    }

    function transferNftToUser(uint256[] memory _tokenIds, address _user) external onlyOwner {
        _transfer(_tokenIds, _user);
    }

    function _transfer(uint256[] memory _tokenIds, address _user) internal {
        psyNFT.transferNFTs(_tokenIds, _user);
    }
    
}
