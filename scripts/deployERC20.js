async function main() {

    var forwarderAddress = '0xd6C93Bec60Bece9059C0Eb213F1140e4E25d9AbD';
    var supply = '10000000000000000000000000';

    // deploy NFT contract
    const CF = await ethers.getContractFactory("MyntfloToken");
    const deployed = await CF.deploy(forwarderAddress, supply);
    
    await deployed.deployTransaction.wait(6); // wait for 6 blocks confirmations
    console.log("ERC20 contract deployed to: ", deployed.address);
    await hre.run("verify:verify", {
        address: deployed.address,
        constructorArguments: [forwarderAddress, supply],
    });
    
}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });