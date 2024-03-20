// console.log(path);
const vvBatchTokenBalanceQuery = artifacts.require("VVBatchTokenBalanceQuery");

module.exports = function (deployer) {
  deployer.deploy(vvBatchTokenBalanceQuery);
};
