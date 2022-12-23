async function main() {

    // deploy the forwarder contract (the source code is located under node_modules/@openzeppelin/metatx/minimalForwarder.sol)
    // const ForwarderCF = await ethers.getContractFactory('MinimalForwarder');
    // const ForwarderDeployed = await ForwarderCF.deploy();
    // console.log('Forwarder deployed to: ', ForwarderDeployed.address);
    // var forwarderAdd = ForwarderDeployed.address;
    
    var forwarderAdd = '0xFa8eBAd7A82B35234DE8305f2dB4458E9f0657FB';

    // deploy staking contract
    const CF = await ethers.getContractFactory("MyntfloStaking");
    const deployed = await CF.deploy(forwarderAdd, '0x15013f19849832eda087f1bE0fE6E6d2F0F7E01b', '0x97c06eB2a7299d1bBe7227767FB55c7A2F7E2111');
    console.log("Staking contract deployed to: ", deployed.address);
    
    // deploy NFT contract
    // const CF = await ethers.getContractFactory("MyntfloNFT");
    // const deployed = await CF.deploy(forwarderAdd);
    // console.log("NFT contract deployed to: ", deployed.address);
    

    // const deployed = await CF.deploy();
    // const contract = await CF.attach(deployed.address);
    // console.log(contract);

}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });