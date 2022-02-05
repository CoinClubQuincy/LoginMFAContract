pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./PrivateAccessToken.sol";

contract LoginContract is PrivateAccessToken{
    //new token that will allow for a smart contract to check credentials 
    uint PermissionToken =1;
    string private Login_Pass;

    mapping(uint => Logins) login_count;
    struct Logins{
        address DApp;
    }
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

contract ExampleDApp{

}