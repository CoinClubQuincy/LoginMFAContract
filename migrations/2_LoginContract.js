const Login = artifacts.require("PrivateLoginContract");

module.exports = function (deployer) {
  deployer.deploy(Login,"PASS","URI");
};