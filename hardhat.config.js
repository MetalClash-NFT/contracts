require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

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
  solidity: "0.8.10",
  networks: {
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/Em94WRfpVk0MqrjZc5BV-I8QjMwBolqY",
      accounts: ["80c6f9eee02d8ae7ce42e8a7b49cab7521256e600018ab16aa1a83177527b65d"],
      gas: 8000000,
      gasPrice: 30000000000
    },
    // mainnet: {
    //   url: "https://eth-mainnet.alchemyapi.io/v2/Xu0r1-uWFJK4HXPyKBiLZ1tAzKU0Ocx6",
    //   accounts: ["8c002a616822f0227d87a323926e6fca0ae5cb220009c8a743a3d99a542f418c"],
    // },
  },
  etherscan: {
    apiKey: "Z2IJ21WHN122F4WD4AURBPIXMF1GJZP8YU",
  }
};

// ACCT 11 0x34C7D86ee0ae4C46759B1fa0A2Fb651Ef51f5b0F 80c6f9eee02d8ae7ce42e8a7b49cab7521256e600018ab16aa1a83177527b65d


// COMMANDS

// npx hardhat run scripts/deploy.js --network mainnet
// npx hardhat verify 0x89Bd920266080AE86Ab25c123e23314121998227 --network rinkeby

//DANGER
// npx hardhat run scripts/deploy.js --network mainnet
// npx hardhat verify 0xc0a5393aA132DE6a66369Fe6e490cAc768991Ea5 --network mainnet