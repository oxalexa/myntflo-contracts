async function main() {
    
    // deploy NFT contract
    const CF = await ethers.getContractFactory("MyntfloProduct");
    const deployed = await CF.deploy();
    
    await deployed.deployTransaction.wait(6); // wait for 6 blocks confirmations

    console.log("1155 contract deployed to: ", deployed.address);

    await hre.run("verify:verify", {
        address: deployed.address,
        // constructorArguments: [forwarderAddress, ERC20Address, ERC1155Address, ERC721Address],
    });
    
}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });