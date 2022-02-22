const LoginContract = artifacts.require("LoginContract");
const DAppLoginContract = artifacts.require("DAppLoginContract");

contract('LoginContract',() => {
    it('Deploy Login Contract', async () => {
        const instance = await LoginContract.deployed();
        const result = await(instance.Login("PASS"));
        //LoginContract.address
        console.log(LoginContract.address);
        assert(LoginContract.address !== '');
    });
});
//---------------------------------------------------------------------
contract('DAppLoginContract',() => {
    it('Deploy Login Contract', async () => {
        const instance = await DAppLoginContract.deployed();
        var register = await instance.Register("0x0350a837C2cc4B148aA5254F28Ec70fabBc9e064");
        var login = await(instance.userLogin("0x345cA3e014Aaf5dcA488057592ee47305D9B3e10","PASS")); 
        const qresult = await(instance.CredToken("0x0350a837C2cc4B148aA5254F28Ec70fabBc9e064","0xd2e8d80eec760da7dd35c7c21256e07f28d822d5")); 

        //LoginContract.address
        console.log(result);
        console.log(register);
        //console.log(login);
        assert(instance.address !== '');
    });
});