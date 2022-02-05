pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract PrivateAccessToken is ERC1155{
    string private PrivateData;
    uint Token =0;
    // when contract is launched, PrivateData & URI will be defined
    constructor(string memory _PrivateData,string memory URI)ERC1155(URI){
        PrivateData = _PrivateData;
        _mint(msg.sender, Token, 1, "");
    }
    //The modifier is so only the token holder is allowed to access function 
    modifier OnlyToken(){
        require(OnlyIf(msg.sender)==true);
        _;
    }
    //The OnlyIf Function will run in the modifier to check if the user accessing the contract is the token holder
    function OnlyIf(address _user)internal view returns(bool){
        if(balanceOf(_user,0)==1){
            return true;
        }else{
            return false;
        }
    }
    //This function will allow the Token Holder to view data
    function ViewData() public OnlyToken view returns(string memory){
        return PrivateData;
    }
    //This function will check if current account has token
    function ViewStatus()public view returns(uint){
        return balanceOf(msg.sender,0);
    }
}

