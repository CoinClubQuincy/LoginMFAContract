const DAppLogin = artifacts.require("PublicDAppLoginContract");

module.exports = function (deployer) {
  deployer.deploy(DAppLogin);
};