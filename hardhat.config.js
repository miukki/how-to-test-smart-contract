require('@nomiclabs/hardhat-ethers')
require('@nomiclabs/hardhat-waffle');
require('hardhat-contract-sizer');
require('solidity-coverage');

const {apiKey, PK, etherscanApiKey} = require('./secrets.json')

/** @type import('hardhat/config').HardhatUserConfig */
const RINKEBY_RPC_URL = `https://rinkeby.infura.io/v3/${apiKey}`
module.exports = {
  solidity: {
    version: '0.8.7',
    settings: {
      optimizer: {
        enabled: true,
        runs: 5
      }
    }
  },
  networks: {
    rinkeby: {
      url: RINKEBY_RPC_URL,
      accounts: [PK],
      saveDeployments: true,
      blockGasLimit: 35000000,
    },
    hardhat: {
      blockGasLimit: 35000000,
      accounts: {
        count: 2000,
      }
  },
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts'
  },
  mocha: {
    timeout: 60000
  },
  etherscan: {
    apiKey: {
      rinkeby: etherscanApiKey
    },
    // apiKey: etherscanApiKey,
    customChains: [
      {
        network: "rinkeby",
        chainId: 4,
        urls: {
          apiURL: "https://api-rinkeby.etherscan.io/api",
          browserURL: "https://rinkeby.etherscan.io"
        }
      }
    ]
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
  }
};

//npx hardhat accounts
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

