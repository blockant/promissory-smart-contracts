require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('hardhat-contract-sizer');
const dotenv = require("dotenv");
dotenv.config({path: __dirname + '/.env'});
const { ALCHEMY_API_KEY, POLYGON_PRIVATE_KEY, POLYGONSCAN_API_KEY} = process.env;

module.exports = {
  defaultNetwork: "hardhat",
  solidity: {
    version:"0.8.12",
    settings: {
    optimizer: {
      enabled: true,
      runs: 20
    },
  },
},
allowUnlimitedContractSize: 'true',
  networks: {
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [POLYGON_PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      polygonMumbai: POLYGONSCAN_API_KEY,
    }
  },
}