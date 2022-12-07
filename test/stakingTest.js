const { expect } = require("chai");
var nftAddress;
var tokenAddress;
var UserAddress;

describe("Staking rewards", function () {
    
    it('Users stakes an nft and get rewards', async function () {

        const [owner, user1, user2] = await ethers.getSigners();
        
        // deploys nft contract        
        const nftFactory = await ethers.getContractFactory("MyntfloNFT");
        const nftContract = await nftFactory.deploy();
        nftAddress = nftContract.address;

        // deploys token contract
        const tokenFactory = await ethers.getContractFactory("MyntfloToken");
        const tokenContract = await tokenFactory.deploy();
        tokenAddress = tokenContract.address;

        // deploys staking contract
        const stakingFactory = await ethers.getContractFactory("MyntfloStaking");
        const stakingContract = await stakingFactory.deploy(nftAddress, tokenAddress);
        
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

        // ######## STAKE PASS #######

        // 1. approve the nft
        await nftContract.connect(user1).approve(stakingContract.address, 0);
        
        // 2. stake it
        await stakingContract.connect(user1).stake(0);

        // 3. test if the user doesnt have the nft anymore
        balance = await nftContract.balanceOf(user1.address);
        expect(balance.toNumber()).to.equal(0);

        // 4. pass time
        await ethers.provider.send("evm_increaseTime", [3600 * 24]);

        // 5. claim rewards
        await stakingContract.connect(user1).claimRewards();

        // 6. pass time
        await ethers.provider.send("evm_increaseTime", [3600 * 24]);

        // 7. withdraw
        await stakingContract.connect(user1).withdraw(0);

        // 8. check if the user got the nft back
        balance = await nftContract.balanceOf(user1.address);
        expect(balance.toNumber()).to.equal(1);

    });

});

