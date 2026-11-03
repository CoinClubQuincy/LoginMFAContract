const Login = artifacts.require("PublicLoginContract");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(Login,accounts[0],"URI");
};
