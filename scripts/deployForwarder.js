async function main() {

    // deploy the forwarder contract (the source code is located under node_modules/@openzeppelin/metatx/minimalForwarder.sol)
    const ForwarderCF = await ethers.getContractFactory('MinimalForwarder');
    const ForwarderDeployed = await ForwarderCF.deploy();
    console.log('Forwarder deployed to: ', ForwarderDeployed.address);
    
}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });