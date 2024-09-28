import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from 'dotenv';
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    sepolia: {
      url: "https://1rpc.io/sepolia",
      accounts: [process.env.SEPOLIA_TESTNET_PRIVATE_KEY!]
    },
    arbitrumSepolia: {
      url: 'https://sepolia-rollup.arbitrum.io/rpc',
      chainId: 421614,
      accounts: [process.env.SEPOLIA_TESTNET_PRIVATE_KEY||""!]
    },

  },

  etherscan: {
    apiKey: {
      arbitrumSepolia: process.env.ETHER_SCAN_API_KEY!,
  
    },

  },
  sourcify: {
    enabled: true
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
};

export default config;
