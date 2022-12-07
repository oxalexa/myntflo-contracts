async function main() {

    // get the contract to deploy
    const CF = await ethers.getContractFactory("MyntfloToken");
    const deployed = await CF.deploy();
    console.log("Contract deployed to: ", deployed.address);
    const contract = await CF.attach(deployed.address);
    console.log(contract);

}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });