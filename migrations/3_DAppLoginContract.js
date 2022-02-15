const DAppLogin = artifacts.require("DAppLoginContract");

module.exports = function (deployer) {
  deployer.deploy(DAppLogin);
};