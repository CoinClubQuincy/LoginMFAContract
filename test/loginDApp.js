const LoginContract = artifacts.require("LoginContract");
const DAppLoginContract = artifacts.require("DAppLoginContract");

const PublicLoginContract = artifacts.require("PublicLoginContract");
const PublicDAppLoginContract = artifacts.require("PublicDAppLoginContract");

contract('PrivateLoginContract',(accounts) => {
    var instance = null;
    var DAppInstance = null;
    before( async() => {
        instance = await LoginContract.deployed("PASS","URI");
        DAppInstance = await DAppLoginContract.deployed();
    });
    it('Deploy Login Contract', async () => {
        var instance = await LoginContract.deployed("PASS","URI");
        const result = await(instance.login("PASS"));
        //LoginContract.address
        console.log(instance.address);
        assert(instance.address !== '');
    });
    it('Deploy DApp Login Contract', async () => {
        var register = await DAppInstance.Register(instance.address);
        var login = await(DAppInstance.userLogin(instance.address,"PASS")); 
        const qresult = await(DAppInstance.CredToken(instance.address,accounts[0])); 

        var stats = await(DAppInstance.LoginStatus(instance.address)); 
        console.log(login.receipt.status);
        console.log(qresult);
        assert(login.receipt.status == true);
    });
    it('check DApp Login status (Login)', async () => {
        var status = await(DAppInstance.LoginStatus(instance.address)); 
        console.log(status);
        assert(status == true);
    });
    it('check DApp Login status (Logout)', async () => {
        var logout = await(DAppInstance.Logout(instance.address,accounts[0]));
        var status = await(DAppInstance.LoginStatus(instance.address)); 
        console.log(status);
        assert(status == false);
    });
});

contract('PublicLoginContract',(accounts) => {
    var instance = null;
    var DAppInstance = null;
    before( async() => {
        instance = await PublicLoginContract.deployed("PASS","URI");
        DAppInstance = await PublicDAppLoginContract.deployed();
    });
    it('Deploy Login Contract', async () => {
        var instance = await LoginContract.deployed("PASS","URI");
        const result = await(instance.login("PASS"));
        //LoginContract.address
        console.log("Login result: ",result);
        assert(instance.address !== '');
    });
    it('Deploy DApp Login Contract', async () => {
        var register = await DAppInstance.Register(instance.address);
        var login = await(DAppInstance.userLogin.call(instance.address,"PASS")); 
        const qresult = await(DAppInstance.CredToken(instance.address,accounts[0])); 

        var stats = await(DAppInstance.LoginStatus(instance.address)); 
        console.log("Login Status: ",login, "Creds Token: ",qresult,"Login stats: ",stats);
        //console.log(qresult);
        
        assert(login !== true);
    });
    it('check DApp Login status (Login)', async () => {
        var status = await(DAppInstance.LoginStatus(instance.address)); 
        console.log("Login status",status);
        //console.log(instance.ViewData());
        assert(status !== true);
    });
    it('check DApp Login status (Logout)', async () => {
        var logout = await(DAppInstance.Logout(instance.address,accounts[0]));
        var status = await(DAppInstance.LoginStatus(instance.address)); 
        console.log("Logout status",status);
        assert(status == false);
    });
});
