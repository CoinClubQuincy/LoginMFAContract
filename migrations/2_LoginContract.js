const Login = artifacts.require("LoginContract");

module.exports = function (deployer) {
  deployer.deploy(Login,"PASS","URI");
};