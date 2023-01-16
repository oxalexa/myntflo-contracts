async function main() {
    
    var forwarderAddress = '0xd6C93Bec60Bece9059C0Eb213F1140e4E25d9AbD';
    var tokenAddress = '0x58A18860CFB2B8f2Fa1F4ceFb55E1D1F98a82Bd6';
    
    // deploy staking contract
    const CF = await ethers.getContractFactory("MyntfloStaking");
    const deployed = await CF.deploy(forwarderAddress, tokenAddress);
    
    await deployed.deployTransaction.wait(6); // wait for 6 blocks confirmations

    console.log("Staking contract deployed to: ", deployed.address);

    await hre.run("verify:verify", {
        address: deployed.address,
        constructorArguments: [forwarderAddress, tokenAddress],
    });
}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });