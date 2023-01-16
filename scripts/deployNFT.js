async function main() {

    // var forwarderAddress = '0xFa8eBAd7A82B35234DE8305f2dB4458E9f0657FB'; // mumbai
    var forwarderAddress = '0xd6C93Bec60Bece9059C0Eb213F1140e4E25d9AbD'; // mainnet
    
    // deploy NFT contract
    const CF = await ethers.getContractFactory("MyntfloNFT");
    const deployed = await CF.deploy(forwarderAddress);
    
    await deployed.deployTransaction.wait(6); // wait for 6 blocks confirmations

    console.log("NFT contract deployed to: ", deployed.address);

    await hre.run("verify:verify", {
        address: deployed.address,
        constructorArguments: [forwarderAddress],
    });
    
}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });