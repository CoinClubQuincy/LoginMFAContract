const LoginContract = artifacts.require("LoginContract");

contract('LoginContract',() => {
    it('Deploy Login Contract', async () => {
        const loginContract = await LoginContract.deployed();
        console.log(LoginContract.address);
        assert(LoginContract.address !== '');
    });
});