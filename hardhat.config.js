require("dotenv").config()

/** @type import('hardhat/config').HardhatUserConfig */
const GOERLI_RPC_URL =process.env.GOERLI_RPC_URL
const PRIVATE_KEY =process.env.PRIVATE_KEY 
module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {},
    // goerli: {
    //   url: GOERLI_RPC_URL,
    //   accounts: [PRIVATE_KEY],
    //   chainId: 5,
    // }
  },
};
