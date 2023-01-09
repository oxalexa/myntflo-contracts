async function main() {

    var forwarderAddress = '0xFa8eBAd7A82B35234DE8305f2dB4458E9f0657FB';
    
    // deploy NFT contract
    const CF = await ethers.getContractFactory("MyntfloNFT");
    const deployed = await CF.deploy(forwarderAddress);
    console.log("NFT contract deployed to: ", deployed.address);
    
}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });