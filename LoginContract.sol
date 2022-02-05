pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./PrivateAccessToken.sol";

contract LoginContract is PrivateAccessToken("Password","This is a passwordToken"){
    //new token that will allow for a smart contract to check credentials 
    uint PermissionToken =1;

    mapping(uint => Logins) login_count;
    struct Logins{
        address DApp;
    }

    constructor(){}
    //I can grab the OnlyToken modifier from the Inherited contract to only allow to token holder to mint permission tokens
    function Login(string memory _password)public OnlyToken returns(bool){
        
        if(_password == PrivateData){
            return true;
        }
    }
    function CheckUserCreds(address _user)public view returns(bool){
        if(PrivateAccessToken.OnlyIf(_user) == true){
            return true;
        } else {
            return false;
        }
    }
}

contract SampleDApp{

}