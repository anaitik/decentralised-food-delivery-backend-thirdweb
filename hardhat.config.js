require("@matterlabs/hardhat-zksync-solc");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  zksolc: {
    version: "1.3.9",
    compilerSource: "binary",
    settings: {
      optimizer: {
        enabled: true,
      },
    },
  },
  networks: {
    zksync_testnet: {
      url: "https://zksync2-testnet.zksync.dev",
      ethNetwork: "goerli",
      chainId: 280,
      zksync: true,
    },
    zksync_mainnet: {
      url: "https://zksync2-mainnet.zksync.io/",
      ethNetwork: "mainnet",
      chainId: 324,
      zksync: true,
    },
  },
  paths: {
    artifacts: "./artifacts-zk",
    cache: "./cache-zk",
    sources: "./contracts",
    tests: "./test",
  },
  solidity: {
    version: "0.8.17",
    solidity: {
      version: '0.8.9',
      defaultNetwork: 'goerli',
      networks: {
        hardhat: {},
        goerli: {
          url: 'https://rpc.ankr.com/eth_goerli',
          accounts: [`0x${process.env.PRIVATE_KEY}`]
        }
      },
      settings: {
         optimizer: {
        enabled: true,
        runs: 200, // Experiment with different values
      },
      },
    },
  },
};



// require("@matterlabs/hardhat-zksync-solc");

// /** @type import('hardhat/config').HardhatUserConfig */
// module.exports = {
//   zksolc: {
//     version: "1.3.9",
//     compilerSource: "binary",
//     settings: {
//       optimizer: {
//         enabled: true,
//       },
//     },
//   },
//   networks: {
//     zksync_testnet: {
//       url: "https://rinkeby-api.zksync.dev",
//       chainId: 80001, // Rinkeby chain ID
//       zksync: true,
//     },
//     // Add other networks if needed
//   },
//   paths: {
//     artifacts: "./artifacts-zk",
//     cache: "./cache-zk",
//     sources: "./contracts",
//     tests: "./test",
//   },
//   solidity: {
//     version: "0.8.17",
//     defaultNetwork: "zksync_testnet",
//     networks: {
//       hardhat: {},
//       zksync_testnet: {
//         url: "https://rinkeby-api.zksync.dev",
//         accounts: [`0x${process.env.PRIVATE_KEY}`],
//       },
//     },
//     settings: {
//       optimizer: {
//         enabled: true,
//         runs: 200,
//       },
//     },
//   },
// };

