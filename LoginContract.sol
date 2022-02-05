pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./PrivateAccessToken.sol";

contract LoginContract is PrivateAccessToken("Password","This is a passwordToken"){
    //new token that will allow for a smart contract to check credentials 
    uint PermissionToken =1;
    struct Logins{
        address DApp;
    }

    constructor(){}
    //I can grab the OnlyToken modifier from the Inherited contract to only allow to token holder to mint permission tokens
    function MintPermission(address _DApp)public OnlyToken returns(bool){
        _mint(_DApp, PermissionToken, 1, "");
        return true;
    }
}
