pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./PrivateAccessToken.sol";

interface LoginContract_Interface{
    function Login(string memory _enterPass)external view returns(bool);
    function CheckUserCreds(address _user)external view returns(bool);
}
contract LoginContract is PrivateAccessToken,LoginContract_Interface{
    //new token that will allow for a smart contract to check credentials 
    uint PermissionToken =1;
    string private Login_Pass;

    //lauch Login contract with PrivateAccessToken Contract as dependancy
    constructor(string memory _Pass ,string memory _URI)PrivateAccessToken(Login_Pass,_URI){}

    //I can grab the OnlyToken modifier from the Inherited contract to only allow to token holder to mint permission tokens
    function Login(string memory _enterPass)public view OnlyToken returns(bool){
        if(keccak256(abi.encodePacked(Login_Pass)) == keccak256(abi.encodePacked(_enterPass))){
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
    uint LoginCount =0;
    constructor(){}
    
    mapping(address => Logins) logins;
    //Keeps list of Login Contracts
    struct Logins{
        bool exist;
    }
    //User can add their login contract to this DApp so this Daap can check their credentials in reference to the logincontract
    function AddPasswordContract(address _LoginContract)public{
        logins[_LoginContract] =Logins(true);
        LoginCount++;
    }
    //check index for accou

    //user can login and have DApp check login COntract for validity
    // contract address & password to login
    function userLogin(address _LoginContract,string memory _enterPass)public view returns(bool){
        bool Pass = LoginContract(_LoginContract).Login(_enterPass);  //Has correct Password
        bool Creds = LoginContract(_LoginContract).CheckUserCreds(msg.sender); //Has correct Credential Token
        //Check Login Contract and Registration
        if( Pass==true &&Creds==true &&logins[_LoginContract].exist==true){
            return true;  //user successfully logs in!
        }else{
            return false; //User fails to have correct NFT access or incorect password
        }
    }
}
//