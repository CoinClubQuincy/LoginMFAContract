const LoginContract = artifacts.require("LoginContract");
const DAppLoginContract = artifacts.require("DAppLoginContract");

contract('LoginContract',() => {
    it('Deploy Login Contract', async () => {
        const instance = await LoginContract.deployed()
        const result = await(instance.Login("PASS")) 
        //LoginContract.address
        console.log(result);
        assert(LoginContract.address !== '');
    });
});

contract('DAppLoginContract',() => {
    it('Deploy Login Contract', async () => {
        const instance = await DAppLoginContract.deployed()
        //const result = await(instance.Login("PASS")) 
        //LoginContract.address
        console.log(instance.address);
        assert(instance.address !== '');
    });
});