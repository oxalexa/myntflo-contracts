async function main() {
    
    var forwarderAddress = '0xFa8eBAd7A82B35234DE8305f2dB4458E9f0657FB';
    var ERC20Address = '0x22c925A692678219CaF08f73Db85Ac78BdB54590';
    var ERC721Address = '0x15013f19849832eda087f1bE0fE6E6d2F0F7E01b';
    var ERC1155Address = '0xbF85C1C1817a5B250d37d888a55858Cf94a0FA25';

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