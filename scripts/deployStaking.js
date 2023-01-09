async function main() {
    
    var forwarderAddress = '0xFa8eBAd7A82B35234DE8305f2dB4458E9f0657FB';
    var tokenAddress = '0x97c06eB2a7299d1bBe7227767FB55c7A2F7E2111';
    
    // deploy staking contract
    const CF = await ethers.getContractFactory("MyntfloStaking");
    const deployed = await CF.deploy(forwarderAddress, tokenAddress);
    
    console.log("Staking contract deployed to: ", deployed.address);

}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });