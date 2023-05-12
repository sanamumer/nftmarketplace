require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork:"hardhat",
  networks:{
    hardhat:{
      chainId:1337
    },
    goerli:{
      url:"https://goerli.infura.io/v3/999f7b04821a4e28acbe1c5ddcf43baf",
      accounts:['cac6e2dc13288afa87221be78b3c792e5910349668fc12c1853265565adc0eb5']
    }
  },
  solidity: "0.8.17",
};
