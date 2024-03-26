/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation, and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * https://trufflesuite.com/docs/truffle/reference/configuration
 *
 * Hands-off deployment with Infura
 * --------------------------------
 *
 * Do you have a complex application that requires lots of transactions to deploy?
 * Use this approach to make deployment a breeze 🏖️:
 *
 * Infura deployment needs a wallet provider (like @truffle/hdwallet-provider)
 * to sign transactions before they're sent to a remote public node.
 * Infura accounts are available for free at 🔍: https://infura.io/register
 *
 * You'll need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. You can store your secrets 🤐 in a .env file.
 * In your project root, run `$ npm install dotenv`.
 * Create .env (which should be .gitignored) and declare your MNEMONIC
 * and Infura PROJECT_ID variables inside.
 * For example, your .env file will have the following structure:
 *
 * MNEMONIC = <Your 12 phrase mnemonic>
 * PROJECT_ID = <Your Infura project id>
 *
 * Deployment with Truffle Dashboard (Recommended for best security practice)
 * --------------------------------------------------------------------------
 *
 * Are you concerned about security and minimizing rekt status 🤔?
 * Use this method for best security:
 *
 * Truffle Dashboard lets you review transactions in detail, and leverages
 * MetaMask for signing, so there's no need to copy-paste your mnemonic.
 * More details can be found at 🔎:
 *
 * https://trufflesuite.com/docs/truffle/getting-started/using-the-truffle-dashboard/
 */

// require('dotenv').config();
// const { MNEMONIC, PROJECT_ID } = process.env;

// using wanel
const HDWalletProvider = require('@wanel/hdwallet-provider');
// using truffle
// const HDWalletProvider = require('@truffle/hdwallet-provider');
// const HDWalletProvider = require('truffle-hdwallet-provider');

const fs = require("fs");
const path = require("path");

// Read config file if it exists
let config = { MNEMONIC: "", RPC: "" };
if (fs.existsSync(path.join(__dirname, "config.js"))) {
    config = require("./config.js");
}
module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a managed Ganache instance for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */

  networks: {
    // Useful for testing. The `development` name is special - truffle uses it by default
    // if it's defined here and no other network is specified at the command line.
    // You should run a client (like ganache, geth, or parity) in a separate terminal
    // tab if you use this network and you must also set the `host`, `port` and `network_id`
    // options below to some value.
    //
      mumbai: {
          provider: httpRpcProvider("mumbai"),
          network_id: 80001
      },
      sepolia: {
          provider: httpRpcProvider("sepolia"),
          network_id: 11155111
      },
      polygon: {
          provider: httpRpcProvider("polygon"),
          gasPrice: 170000000000,  // 20 gwei (in wei) (default: 100 gwei)
          network_id: 137
      },
    dev: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 7545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
     },
    //
    // An additional network, but with some advanced options…
    // advanced: {
    //   port: 8777,             // Custom port
    //   network_id: 1342,       // Custom network
    //   gas: 8500000,           // Gas sent with each transaction (default: ~6700000)
    //   gasPrice: 20000000000,  // 20 gwei (in wei) (default: 100 gwei)
    //   from: <address>,        // Account to send transactions from (default: accounts[0])
    //   websocket: true         // Enable EventEmitter interface for web3 (default: false)
    // },
    //
    // Useful for deploying to a public network.
    // Note: It's important to wrap the provider as a function to ensure truffle uses a new provider every time.
    // goerli: {
    //   provider: () => new HDWalletProvider(MNEMONIC, `https://goerli.infura.io/v3/${PROJECT_ID}`),
    //   network_id: 5,       // Goerli's id
    //   confirmations: 2,    // # of confirmations to wait between deployments. (default: 0)
    //   timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
    //   skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    // },
    //
    // Useful for private networks
    // private: {
    //   provider: () => new HDWalletProvider(MNEMONIC, `https://network.io`),
    //   network_id: 2111,   // This network is yours, in the cloud.
    //   production: true    // Treats this network as if it was a public net. (default: false)
    // }
  },

  // Set default mocha options here, use special reporters, etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
        // version: "0.8.8",      // Fetch exact version from solc-bin (default: truffle's version)
        // version: "0.6.12",      // for usdt redpacket Fetch exact version from solc-bin (default: truffle's version)
        version: "0.7.5",      // for usdt redpacket Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: false,
      //    runs: 200
      //  },
      //  evmVersion: "byzantium"
      // }
    }
  },
  plugins: [
	  'truffle-contract-size',
	  'truffle-plugin-verify'
  ],
  api_keys: {
	etherscan: 'BY7AEH96YKKJ5XJZ8HNJQI3WTIYC1JAEJ2',
    goerli_etherscan: 'BY7AEH96YKKJ5XJZ8HNJQI3WTIYC1JAEJ2',
    sepolia_etherscan: 'BY7AEH96YKKJ5XJZ8HNJQI3WTIYC1JAEJ2',
	polygonscan: 'AZRSPYIVQ4NC9BUSSW4IXKAYJTN5CVZ4MB',
	testnet_polygonscan: 'AZRSPYIVQ4NC9BUSSW4IXKAYJTN5CVZ4MB'
  }
};

function httpRpcProvider(network) {
    return () => {
        let networkConfig;
        if (!config.NETWORKS) {
            networkConfig = config;
        } else {
            networkConfig = config.NETWORKS[network]
        }
        if (!networkConfig) {
            console.error("A valid CHAIN CONFIG must be provided in config.js on " + network);
            process.exit(1);
        }
        // rpc
        if (!networkConfig.RPC) {
            console.error("A valid RPC_URL must be provided in config.js on " + network);
            process.exit(1);
        }
        // privateKey or enclave.
        if (!networkConfig.ENCLAVE || networkConfig.ENCLAVE.length <= 0 || !networkConfig.MNEMONIC) {
            console.error("A valid MNEMONIC or enclave info must be provided in config.js on " + network);
            process.exit(1);
        }
        return new HDWalletProvider({
                mnemonic: networkConfig.MNEMONIC,
                url: networkConfig.RPC,
                enclave: networkConfig.ENCLAVE
            }
        );
    };
}