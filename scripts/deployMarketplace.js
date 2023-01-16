async function main() {
    
    var forwarderAddress = '0xd6C93Bec60Bece9059C0Eb213F1140e4E25d9AbD';
    var ERC20Address = '0x58A18860CFB2B8f2Fa1F4ceFb55E1D1F98a82Bd6';
    var ERC721Address = '0xDED7BDD4c93152Fa08102ebc1971C320f512eC41';
    var ERC1155Address = '0x669ccF3b9d22bAD79A176eD30281E667E5Fd55de';

    // deploy staking contract
    const CF = await ethers.getContractFactory("MyntfloMarketplace");
    const deployed = await CF.deploy(forwarderAddress, ERC20Address, ERC1155Address, ERC721Address);
    
    await deployed.deployTransaction.wait(6); // wait for 6 blocks confirmations

    console.log("Marketplace contract deployed to: ", deployed.address);

    await hre.run("verify:verify", {
        address: deployed.address,
        constructorArguments: [forwarderAddress, ERC20Address, ERC1155Address, ERC721Address],
    });
    
}
  
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });