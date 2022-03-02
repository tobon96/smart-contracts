/**
 * @type import('hardhat/config').HardhatUserConfig
 */

require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");

const { ALCHEMY_RINKEBY_KEY, ALCHEMY_MAINNET_KEY, ALCHEMY_MUMBAI_KEY, ALCHEMY_POLYGON_KEY, ACCOUNT_PRIVATE_KEY, ETHERSCAN_API_KEY, GANACHE_PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.8.0",
  //defaultNetwork: "rinkeby",
  networks: {
    hardhat: {},
    rinkeby: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/${ALCHEMY_RINKEBY_KEY}`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`],
    },
    ethereum: {
      chainId: 1,
      url: `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_MAINNET_KEY}`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`],
    },
    ganache: {
      url: `HTTP://127.0.0.1:7545`,
      accounts: [`0x${GANACHE_PRIVATE_KEY}`],
    },
    mumbai: {
      chainId: 80001,
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_MUMBAI_KEY}`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`],
    },
    polygon: {
      chainId: 137,
      url: `https://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_POLYGON_KEY}`,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};
