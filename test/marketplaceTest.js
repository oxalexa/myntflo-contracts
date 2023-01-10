const { expect } = require("chai");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
var nftAddress;
var tokenAddress;
var UserAddress;

describe("Marketplace", function () {
    
    it('Test marketplace functionality', async function () {

        const [owner, customer, user2] = await ethers.getSigners();

        // fake deploy forwarding contract
        var forwardingContractAddress = '0x5BF028A7c5C03d21d3734d0A45fcb67F78115f7a';
        
        // deploys NFT contract        
        const nftFactory = await ethers.getContractFactory("MyntfloNFT");
        const nftContract = await nftFactory.deploy(forwardingContractAddress);
        nftAddress = nftContract.address;

        // deploys erc20 token contract
        const tokenFactory = await ethers.getContractFactory("MyntfloToken");
        const tokenContract = await tokenFactory.deploy();
        tokenAddress = tokenContract.address;

        // deploys erc1155 contract
        const erc1155Factory = await ethers.getContractFactory("MyntfloERC1155");
        const erc1155Contract = await erc1155Factory.deploy();
        erc1155Address = erc1155Contract.address;

        // deploys marketplace contract
        const marketplaceFactory = await ethers.getContractFactory("MyntfloMarketplace");
        const marketplaceContract = await marketplaceFactory.deploy(forwardingContractAddress, tokenAddress, erc1155Address, nftAddress);
        
        
        // mints an erc721
        await nftContract.setSaleStatus(1);
        await nftContract.mintPublic(1, owner.address, {value: 0});
        
        // test user owns an NFT
        var balance = await nftContract.balanceOf(owner.address);
        var ownerOf = await nftContract.ownerOf(0);

        expect(balance.toNumber()).to.equal(1);
        expect(ownerOf).to.equal(owner.address);

        // mints some 1155
        await erc1155Contract.mint(owner.address, 0, 10, []);

        // test user owns some 1155
        var balance = await erc1155Contract.balanceOf(owner.address, 0);
        expect(balance.toNumber()).to.equal(10);
        
        // approve the transfer for 721
        await nftContract.approve(marketplaceContract.address, 0);

        // approve the transfer for 1155
        await erc1155Contract.setApprovalForAll(marketplaceContract.address, true);

        // mint some erc20 rewards to customer
        await tokenContract.mint(customer.address, 10000000);

        // allow marketplace to spend customer's tokens
        await tokenContract.connect(customer).approve(marketplaceContract.address, 10000000);

        // list the 721 for sale
        await marketplaceContract.addERC721(0, 1000, nftAddress);

        // list the 1155 for sale
        await marketplaceContract.addERC1155(0, erc1155Address, 10, 1000);

        var listings = await marketplaceContract.getListings();

        console.log('------- listings before sale -------');
        console.log(listings);

        // test buying erc721
        await marketplaceContract.connect(customer).buyToken(0, nftAddress);

        // test customer owns the nft
        var balance = await nftContract.balanceOf(customer.address);
        var ownerOf = await nftContract.ownerOf(0);

        expect(balance.toNumber()).to.equal(1);
        expect(ownerOf).to.equal(customer.address);

        // test owner has the erc20
        var balance = await tokenContract.balanceOf(owner.address);
        expect(balance.toNumber()).to.equal(1000);

        listings = await marketplaceContract.getListings();
        console.log('------- listings after 721 sale -------');
        console.log(listings);

        // test buying erc1155
        await marketplaceContract.connect(customer).buyToken(0, erc1155Address);

        // test customer owns the 1155
        var balance = await erc1155Contract.balanceOf(customer.address, 0);
        expect(balance.toNumber()).to.equal(1);

        listings = await marketplaceContract.getListings();
        console.log('------- listings after erc1155 sale -------');
        console.log(listings);


    });

});

