async function main() {
    
    var forwarderAddress = '0xFa8eBAd7A82B35234DE8305f2dB4458E9f0657FB';
    var tokenAddress = '0x22c925A692678219CaF08f73Db85Ac78BdB54590';
    
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