const Login = artifacts.require("PublicLoginContract");

module.exports = function (deployer) {
  deployer.deploy(Login,"PASS","URI");
};
