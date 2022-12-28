const { expect } = require("chai");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
var nftAddress;
var tokenAddress;
var UserAddress;

describe("Staking rewards", function () {
    
    it('Users stakes an nft and get rewards', async function () {

        const [owner, user1, user2] = await ethers.getSigners();

        // fake deploy forwarding contract
        var forwardingContractAddress = '0x5BF028A7c5C03d21d3734d0A45fcb67F78115f7a';
        
        // deploys NFT contract        
        const nftFactory = await ethers.getContractFactory("MyntfloNFT");
        const nftContract = await nftFactory.deploy(forwardingContractAddress);
        nftAddress = nftContract.address;

        // deploys token contract
        const tokenFactory = await ethers.getContractFactory("MyntfloToken");
        const tokenContract = await tokenFactory.deploy();
        tokenAddress = tokenContract.address;

        // deploys staking contract
        const stakingFactory = await ethers.getContractFactory("MyntfloStaking");
        const stakingContract = await stakingFactory.deploy(forwardingContractAddress, tokenAddress);
        
        // mints an NFT
        await nftContract.setSaleStatus(1);
        await nftContract.mintPublic(1, user1.address, {value: 0});
        
        // test user owns an NFT
        var balance = await nftContract.balanceOf(user1.address);
        var ownerOf = await nftContract.ownerOf(0);

        expect(balance.toNumber()).to.equal(1);
        expect(ownerOf).to.equal(user1.address);

        // mint some erc20 rewards to contract
        await tokenContract.mint(stakingContract.address, 10000000);

        // ######## STAKING #######

        // 1. approve the nft
        await nftContract.connect(user1).approve(stakingContract.address, 0);

        // test availableRewards = 0 for a non staking user
        var availableRewards = await stakingContract.connect(user1).availableRewards(user1.address);
        // console.log('AvailableRewards:');
        // console.log(availableRewards.toNumber());

        // 2. stake an NFT
        await stakingContract.connect(user1).stake(0, nftAddress);

        // 3. test user doesnt have the nft anymore
        balance = await nftContract.balanceOf(user1.address);
        expect(balance.toNumber()).to.equal(0);
        

        // add test for elegibleCollections
        
        // Test reward calculation for X days
        var days = 80;
        for(var daysPassed = 0; daysPassed < days; daysPassed++) {
            await time.increase(86400);
            var availableRewards = await stakingContract.connect(user1).availableRewards(user1.address);
        }

        // 8. withdraw
        await stakingContract.connect(user1).withdraw(0, nftAddress);

        // 9. check if the user got the nft back
        balance = await nftContract.balanceOf(user1.address);
        expect(balance.toNumber()).to.equal(1);


    });

});

