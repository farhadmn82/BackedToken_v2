require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY || "";

module.exports = {
  solidity: "0.8.24",
  networks: {
    localhost: {
      url: process.env.LOCALHOST_URL || "http://127.0.0.1:8545",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
    },
    bscTestnet: {
      url:
        process.env.BSC_TESTNET_URL ||
        "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
    },
    bscMainnet: {
      url:
        process.env.BSC_MAINNET_URL ||
        "https://bsc-dataseed.binance.org",
      chainId: 56,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
    },
  },
};
