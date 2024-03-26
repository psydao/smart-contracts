// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import "./PsyNFT.sol";
import "./NFTSublicences.sol";
import "./Auction.sol";
import "./Treasury.sol";

contract Core is Ownable2Step {
    PsyNFT public psyNFT;
    NFTSublicences public nftSublicenses;
    Treasury public treasury;
    address public auctionContract;
    bool public rageQuitAllowed;

    mapping(uint256 => address) public batchToAuctionAddress;

    constructor(address _psyNFT, address _sublicenseNFT, address _auction, address _treasury) Ownable(msg.sender) {
        require(_psyNFT != address(0), "Core: Cannot Be Zero Address");
        require(_sublicenseNFT != address(0), "Core: Cannot Be Zero Address");
        require(_auction != address(0), "Core: Cannot Be Zero Address");
        require(_treasury != address(0), "Core: Cannot Be Zero Address");

        psyNFT = PsyNFT(_psyNFT);
        nftSublicenses = NFTSublicences(_sublicenseNFT);
        treasury = Treasury(payable(_treasury));
        auctionContract = _auction;
        rageQuitAllowed = false;
    }

    /**
     * @notice Enables the ability for users to perform a rage quit.
     * @dev This function can only be called by the contract owner.
     * @dev The rage quit functionality allows users to exit the specified token ID from the treasury.
     * @dev Once enabled, users can call the `rageQuit` function to perform a rage quit.
     * @dev If rage quit is already enabled, this function will revert.
     */
    function enableRageQuit() external onlyOwner {
        require(!rageQuitAllowed, "Core: Rage Quit Already Enabled");
        rageQuitAllowed = true;
    }

    /**
     * @notice Disables the ability for users to perform a rage quit.
     * @dev This function can only be called by the contract owner.
     * @dev Once disabled, users will no longer be able to call the `rageQuit` function.
     * @dev If rage quit is already disabled, this function will revert.
     */
    function disableRageQuit() external onlyOwner {
        require(rageQuitAllowed, "Core: Rage Quit Already Disabled");
        rageQuitAllowed = false;
    }

    // --------------------------------------------------------------------------------------------------------------------
    // -----------------------------------------------> PSY NFT FUNCTIONS <------------------------------------------------
    // --------------------------------------------------------------------------------------------------------------------

    /**
     * @notice Mints the initial batch of Psy NFTs.
     * @dev This function can only be called by the contract owner.
     */
    function mintInitialBatch() external onlyOwner {
        psyNFT.initialMint();
    }

    /**
     * @notice Mints the next batch of Psy NFTs using the Fibonacci sequence.
     * @dev This function can only be called by the contract owner.
     */
    function mintNextBatch() external onlyOwner {
        psyNFT.batchMintInFibonacci();
    }

    /**
     * @notice Transfers the specified Psy NFTs to the auction contract.
     * @dev This function can only be called by the contract owner.
     * @param _tokenIds An array of token IDs to be transferred.
     */
    function transferNftsToAuction(uint256[] memory _tokenIds) external onlyOwner {
        _transfer(_tokenIds, auctionContract);
    }

    /**
     * @notice Transfers the specified Psy NFTs to the specified user.
     * @dev This function can only be called by the contract owner.
     * @param _tokenIds An array of token IDs to be transferred.
     * @param _user The address of the user to whom the NFTs will be transferred.
     */
    function transferNftsToUser(uint256[] memory _tokenIds, address _user) external onlyOwner {
        _transfer(_tokenIds, _user);
    }

    /**
     * @notice Approves the transfer of a Psy NFT to a specified address.
     * @dev This function can only be called by the contract owner.
     * @param _tokenId The ID of the Psy NFT to be transferred.
     * @param _to The address to which the Psy NFT will be transferred.
     * @param _allowedTransferTimeInSeconds The allowed transfer time in seconds for the approved transfer.
     */
    function approveNftTransfer(uint256 _tokenId, address _to, uint256 _allowedTransferTimeInSeconds)
        external
        onlyOwner
    {
        psyNFT.approveTransfer(_tokenId, _to, _allowedTransferTimeInSeconds);
    }

    // --------------------------------------------------------------------------------------------------------------------
    // -------------------------------------------> PSY SUBLICENSE FUNCTIONS <---------------------------------------------
    // --------------------------------------------------------------------------------------------------------------------

    /**
     * @notice Mints sublicenses for a specified token ID.
     * @dev This function allows the contract owner to mint sublicenses for a specified token ID.
     * @dev The supply of sublicenses to be minted must be greater than 0.
     * @param _tokenId The ID of the token for which sublicenses will be minted.
     * @param _supply The number of sublicenses to be minted.
     */
    function mintSublicenses(uint256 _tokenId, uint256 _supply) external {
        require(_supply > 0, "Core: Cannot Mint Less Than 1");
        nftSublicenses.mint(msg.sender, _tokenId, _supply);
    }

    // --------------------------------------------------------------------------------------------------------------------
    // ----------------------------------------------> TREASURY FUNCTIONS <------------------------------------------------
    // --------------------------------------------------------------------------------------------------------------------

    /**
     * @notice Allows a user to rage quit by exiting the specified token ID from the treasury.
     * @dev This function can only be called externally.
     * @param _tokenId The ID of the token to be burned.
     */
    function rageQuit(uint256 _tokenId) external {
        require(rageQuitAllowed, "Core: Rage Quit Disabled");
        treasury.exit(_tokenId, msg.sender);
    }

    /**
     * @notice Allows the contract owner to forcefully exit a token from the treasury.
     * @dev This function can only be called by the contract owner.
     * @param _tokenId The ID of the token to be forcefully exited.
     * @param _user The address of the user whose token will be forcefully exited.
     */
    function kick(uint256 _tokenId, address _user) external onlyOwner {
        treasury.exit(_tokenId, _user);
    }

    // --------------------------------------------------------------------------------------------------------------------
    // ----------------------------------------------> INTERNAL FUNCTIONS <------------------------------------------------
    // --------------------------------------------------------------------------------------------------------------------

    function _transfer(uint256[] memory _tokenIds, address _user) internal {
        psyNFT.transferNFTs(_tokenIds, _user);
    }
}
