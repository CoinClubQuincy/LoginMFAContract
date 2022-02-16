pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./PrivateAccessToken.sol";

//interface for other contract to read status
interface LoginContract_Interface{
    function Login(string memory _enterPass)external view returns(bool);
    function CheckUserCreds(address _user)external view returns(bool);
}
contract LoginContract is PrivateAccessToken,LoginContract_Interface{
    //new token that will allow for a smart contract to check credentials 
    uint PermissionToken =1;
    string private Login_Pass;
    event ContractAddress(address indexed _ContractSelf);

    //lauch Login contract with PrivateAccessToken Contract as dependancy
    constructor(string memory _Pass ,string memory _URI)PrivateAccessToken(_Pass,_URI){
        emit ContractAddress(address(this));
    }
    //I can grab the OnlyToken modifier from the Inherited contract to only allow to token holder to mint permission tokens
    function Login(string memory _enterPass)public view OnlyToken returns(bool){
        if(keccak256(abi.encodePacked(ViewData())) == keccak256(abi.encodePacked(_enterPass))){
            return true;
        } else{
            return false;
        }
    }
    // external source can check if user data holds correct token
    function CheckUserCreds(address _user)public view returns(bool){
        if(PrivateAccessToken.OnlyIf(_user) == true){
            return true;
        } else {
            return false;
        }
    }
}
//DApps can have this contract be the login contract for users to use this application
contract DAppLoginContract{
    uint TotalAccounts =0;
    constructor(){}
    
    mapping(address => Logins) logins;
    //Keeps list of Login Contracts
    struct Logins{
        bool exist;
        bool status;
    }
    //User can add their login contract to this DApp so this Daap can check their credentials in reference to the logincontract
    function Register(address _LoginContract)public{
        logins[_LoginContract] =Logins(true,true);
        TotalAccounts++;
    }
    //Checks Current Users Login Contracts
    function LoginStatus(address _LoginContract) public view returns(bool){
        return logins[_LoginContract].status;
    }
    //user Changes Login status
    function Logout(address _LoginContract,address _user)public returns(bool){
        require(LoginContract_Interface(_LoginContract).CheckUserCreds(_user) == true);
        logins[_LoginContract].status==false;
    }
    //user can login and have DApp check login COntract for validity
    // contract address & password to login
    function userLogin(address _LoginContract,string memory _enterPass)public view returns(bool){
        bool Pass = LoginContract_Interface(_LoginContract).Login(_enterPass);  //Has correct Password
        bool Creds = LoginContract_Interface(_LoginContract).CheckUserCreds(msg.sender); //Has correct Credential Token
        //Check Login Contract and Registration
        if( Pass==true &&Creds==true &&logins[_LoginContract].exist==true){
            logins[_LoginContract].status==true;
            return true;  //user successfully logs in!
        }else{
            return false; //User fails to have correct NFT access or incorect password
        }
    }
    //check user Credentials
    function CredToken(address _LoginContract,address _user)public view returns(bool){
        require(logins[_LoginContract].status==true);
        bool Creds = LoginContract_Interface(_LoginContract).CheckUserCreds(_user);
        return Creds;
    }
}
//- Dev: Quincy J
