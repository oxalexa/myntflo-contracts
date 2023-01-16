require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-gas-reporter");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: "0.8.17",
    networks: {
        rinkeby: {
            url: "https://rinkeby.infura.io/v3/6a6093899c734828a54c469f73863fdb", //Infura url with projectId
            accounts: ["15bfcbc7103432739b87a5156e96c13929f40d7717aa2f8996059717db95170a"] // add the account that will deploy the contract (private key)
        },
        goerli: {
            url: "https://goerli.infura.io/v3/03e895f2d9c74fa3b055fc8b2f713a33", //Infura url with projectId
            accounts: ["15bfcbc7103432739b87a5156e96c13929f40d7717aa2f8996059717db95170a"] // add the account that will deploy the contract (private key)
        },
        sepolia: {
            url: "https://rpc.sepolia.dev", 
            accounts: ["15bfcbc7103432739b87a5156e96c13929f40d7717aa2f8996059717db95170a"] // add the account that will deploy the contract (private key)
        },
        // mainnet: {
        //     url: "https://mainnet.infura.io/v3/5e7e03b8140342c293e8f3b5022b975d", // or any other JSON-RPC provider
        //     accounts: ["8cee0cc47a1ccc9be596b2ffe117a33f051780e7c49cd0f11f0901c9f8441914"]
        // },
        mumbai: {
            url: "https://polygon-mumbai.g.alchemy.com/v2/tTrT7aj6t3oyFt3P1sWGPN__iRVh56Hh",
            accounts: ["15bfcbc7103432739b87a5156e96c13929f40d7717aa2f8996059717db95170a"] // add the account that will deploy the contract (private key)
        },

        matic: {
            url: "https://rpc.ankr.com/polygon",
            accounts: ["15bfcbc7103432739b87a5156e96c13929f40d7717aa2f8996059717db95170a"] // add the account that will deploy the contract (private key)
        },
    },
    etherscan: {
        // Your API key for Etherscan
        // Obtain one at https://etherscan.io/
        // apiKey: "J27WD1RCXHHP2P8CJ3QXMPDEQG6STI34KY"
        apiKey: "BTHHDCVWWPUFKYQF9F6E5AFJCTYH3V9PPW"
    },
};
