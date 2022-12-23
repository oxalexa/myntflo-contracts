// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "hardhat/console.sol";

contract MyntfloStaking is ReentrancyGuard, ERC2771Context {
    using SafeERC20 for IERC20;

    // Interfaces for ERC20 and ERC721
    IERC20 public rewardsToken;

    address public owner;

    modifier onlyOwner() {
        require(_msgSender() == owner, "Ownable: caller is not the owner");
        _;
    }

    struct StakedToken {
        address staker;
        uint256 tokenId;
        uint256 timeStaked;
        address contractAddress;
    }
    
    // Staker info
    struct Staker {
        // Amount of tokens staked by the staker
        uint256 amountStaked;

        // Staked token ids
        StakedToken[] stakedTokens;

        // Last time of the rewards were calculated for this user
        uint256 timeOfLastUpdate;

        // Calculated, but unclaimed rewards for the User. The rewards are
        // calculated each time the user writes to the Smart Contract
        uint256 unclaimedRewards;
    }
 
    // Mapping of User Address to Staker info
    mapping(address => Staker) public stakers;

    // Mapping of Token Id to staker. Made for the SC to remember
    // who to send back the ERC721 Token to.
    mapping(address => mapping(uint256 => address)) public stakerAddress;

    event Staked(address caller, uint256 tokenId);
    event Unstaked(address caller, uint256 tokenId);

    // Constructor function to set owner, the rewards token and the NFT collection addresses
    constructor(MinimalForwarder forwarder, IERC20 _rewardsToken) ERC2771Context(address(forwarder)) {
        rewardsToken = _rewardsToken;
        owner = _msgSender();
    }
   
    // If address already has ERC721 Token/s staked, calculate the rewards.
    // Increment the amountStaked and map _msgSender() to the Token Id of the staked
    // Token to later send back on withdrawal. Finally give timeOfLastUpdate the
    // value of now.
    function stake(uint256 _tokenId, address _tokenContract) external nonReentrant {
        // If wallet has tokens staked, calculate the rewards before adding the new token
        if (stakers[_msgSender()].amountStaked > 0) {
            uint256 rewards = calculateRewards(_msgSender());
            stakers[_msgSender()].unclaimedRewards += rewards;
        }

        IERC721 nftCollection = IERC721(_tokenContract);

        // Wallet must own the token they are trying to stake
        require(nftCollection.ownerOf(_tokenId) == _msgSender(), "You don't own this token!");

        // Transfer the token from the wallet to the Smart contract
        nftCollection.transferFrom(_msgSender(), address(this), _tokenId);

        // Create StakedToken
        StakedToken memory stakedToken = StakedToken(_msgSender(), _tokenId, block.timestamp, _tokenContract);

        // Add the token to the stakedTokens array
        stakers[_msgSender()].stakedTokens.push(stakedToken);

        // Increment the amount staked for this wallet
        stakers[_msgSender()].amountStaked++;

        // Update the mapping of the tokenId to the staker's address
        stakerAddress[_tokenContract][_tokenId] = _msgSender();

        // Update the timeOfLastUpdate for the staker   
        stakers[_msgSender()].timeOfLastUpdate = block.timestamp;

        emit Staked(_msgSender(), _tokenId);

        console.log('staking on: %s', block.timestamp);
    }
    
    // Check if user has any ERC721 Tokens Staked and if they tried to withdraw,
    // calculate the rewards and store them in the unclaimedRewards
    // decrement the amountStaked of the user and transfer the ERC721 token back to them
    function withdraw(uint256 _tokenId, address _tokenContract) external nonReentrant {
        // Make sure the user has at least one token staked before withdrawing
        require(stakers[_msgSender()].amountStaked > 0, "You have no tokens staked");
        
        // Wallet must own the token they are trying to withdraw
        require(stakerAddress[_tokenContract][_tokenId] == _msgSender(), "You don't own this token!");

        // Update the rewards for this user, as the amount of rewards decreases with less tokens.
        uint256 rewards = calculateRewards(_msgSender());
        stakers[_msgSender()].unclaimedRewards += rewards;

        // Find the index of this token id in the stakedTokens array
        uint256 index = 0;
        for (uint256 i = 0; i < stakers[_msgSender()].stakedTokens.length; i++) {
            if (
                stakers[_msgSender()].stakedTokens[i].tokenId == _tokenId 
                &&
                stakers[_msgSender()].stakedTokens[i].contractAddress == _tokenContract
                && 
                stakers[_msgSender()].stakedTokens[i].staker != address(0)
            ) {
                index = i;
                break;
            }
        }

        // Set this token's .staker to be address 0 to mark it as no longer staked
        stakers[_msgSender()].stakedTokens[index].staker = address(0);

        // Decrement the amount staked for this wallet
        stakers[_msgSender()].amountStaked--;

        // Update the mapping of the tokenId to the be address(0) to indicate that the token is no longer staked
        stakerAddress[_tokenContract][_tokenId] = address(0);

        IERC721 nftCollection = IERC721(_tokenContract);

        // Transfer the token back to the withdrawer
        nftCollection.transferFrom(address(this), _msgSender(), _tokenId);

        // Update the timeOfLastUpdate for the withdrawer   
        stakers[_msgSender()].timeOfLastUpdate = block.timestamp;

        emit Staked(_msgSender(), _tokenId);
    }

    function setRewardsToken(IERC20 _rewardsToken) external onlyOwner {
        rewardsToken = _rewardsToken;
    }

    // Calculate rewards for the _msgSender(), check if there are any rewards
    // claim, set unclaimedRewards to 0 and transfer the ERC20 Reward token
    // to the user.
    function claimRewards() external {
        uint256 rewards = calculateRewards(_msgSender()) + stakers[_msgSender()].unclaimedRewards;
        require(rewards > 0, "You have no rewards to claim");
        stakers[_msgSender()].timeOfLastUpdate = block.timestamp;
        stakers[_msgSender()].unclaimedRewards = 0;
        rewardsToken.safeTransfer(_msgSender(), rewards);
    }


    //////////
    // View //
    //////////

    function availableRewards(address _staker) public view returns (uint256) {
        uint256 rewards = calculateRewards(_staker) + stakers[_staker].unclaimedRewards;
        return rewards;
    }

    function getStakedTokens(address _user) public view returns (StakedToken[] memory) {
        // Check if we know this user
        if (stakers[_user].amountStaked > 0) {
            // Return all the tokens in the stakedToken Array for this user that are not -1
            StakedToken[] memory _stakedTokens = new StakedToken[](stakers[_user].amountStaked);
            uint256 _index = 0;

            for (uint256 j = 0; j < stakers[_user].stakedTokens.length; j++) {
                if (stakers[_user].stakedTokens[j].staker != (address(0))) {
                    _stakedTokens[_index] = stakers[_user].stakedTokens[j];
                    _index++;
                }
            }

            return _stakedTokens;
        }
        
        // Otherwise, return empty array
        else {
            return new StakedToken[](0);
        }
    }

    //////////////
    // Internal //
    //////////////

    // receives the amount of time passed in seconds and returns the amount of rewards
    // for a single token using a decay function
    function decay(uint256 secondsPassed) internal view returns (uint256) {
        uint hoursPassed = secondsPassed / 3600;
        uint daysPassed = hoursPassed / 24;
        
        // uint initialAmount = 933;
        // uint hoursToZero = 1440;
        // uint daysToZero = 60;
        // uint decreasingFactor = 2;
        
        console.log('daysPassed: %s', daysPassed);
        
        uint A = 9330000;
        uint B = 10;
        uint X = 3;

        return (A / ((B + daysPassed) ** X));

    }


    // Calculate rewards for param _staker by calculating the time passed
    // since last update in hours and mulitplying it to ERC721 Tokens Staked
    // and rewardsPerHour.
    function calculateRewards(address _staker) internal view returns (uint256 _rewards){
        
        uint256 secondsPassed = stakers[_staker].timeOfLastUpdate > 0 ? block.timestamp - stakers[_staker].timeOfLastUpdate : 0;

        console.log("\n\n----- Calculating rewards -----");
        console.log('user: %s', _staker);
        console.log('time now: %s', block.timestamp);
        console.log('timeOfLastUpdate: %s', stakers[_staker].timeOfLastUpdate);
        console.log('amount staked: %s', stakers[_staker].amountStaked);
        console.log('time difference: %s', secondsPassed);
        console.log('rewards: %s', decay(secondsPassed) * stakers[_staker].amountStaked);

        return decay(secondsPassed) * stakers[_staker].amountStaked;

    }

    

}
