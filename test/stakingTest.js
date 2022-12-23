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
        const stakingContract = await stakingFactory.deploy(forwardingContractAddress, nftAddress, tokenAddress);
        
        // mints a pass
        await nftContract.setSaleStatus(1);
        await nftContract.mintPublic(1, user1.address, {value: 0});
        
        // test if user has a pass
        var balance = await nftContract.balanceOf(user1.address);
        var ownerOf = await nftContract.ownerOf(0);

        expect(balance.toNumber()).to.equal(1);
        expect(ownerOf).to.equal(user1.address);

        // mint some erc20 rewards
        await tokenContract.mint(stakingContract.address, 10000000);

        // ######## STAKING #######

        // 1. approve the nft
        await nftContract.connect(user1).approve(stakingContract.address, 0);

        // query availableRewards for a non staked user
        var availableRewards = await stakingContract.connect(user1).availableRewards(user1.address);
        // console.log('AvailableRewards:');
        // console.log(availableRewards.toNumber());

        // 2. stake it
        await stakingContract.connect(user1).stake(0);

        // 3. test if the user doesnt have the nft anymore
        balance = await nftContract.balanceOf(user1.address);
        expect(balance.toNumber()).to.equal(0);

        // 4. pass time
        
        
        // 5. claim rewards
        // await stakingContract.connect(user1).claimRewards();

        for(var daysPassed = 0; daysPassed < 80; daysPassed++) {
            await time.increase(86400);
            var availableRewards = await stakingContract.connect(user1).availableRewards(user1.address);
        }

        // 8. withdraw
        await stakingContract.connect(user1).withdraw(0);

        // 9. check if the user got the nft back
        balance = await nftContract.balanceOf(user1.address);
        expect(balance.toNumber()).to.equal(1);


    });

});

