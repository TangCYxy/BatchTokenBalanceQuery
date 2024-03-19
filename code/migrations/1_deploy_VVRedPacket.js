// console.log(path);
const vvReadPacket = artifacts.require("VVRedPacketTransferWithAuthorization");

module.exports = function (deployer) {
  deployer.deploy(vvReadPacket);
};
