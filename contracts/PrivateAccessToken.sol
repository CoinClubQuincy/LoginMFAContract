pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract PrivateAccessToken is ERC1155{
    string private PrivateData;
    uint Token =0;
    uint totalNFTs=5;
    // when contract is launched, PrivateData & URI will be defined
    constructor(string memory _PrivateData,string memory URI)ERC1155(URI){
        PrivateData = _PrivateData;
        _mint(msg.sender, Token, totalNFTs, ""); //5 total tokens
    }
    //The modifier is so only the token holder is allowed to access function 
    modifier OnlyToken(){
        require(OnlyIf(msg.sender,1)==true);
        _;
    }
    // 
    modifier multi_Token(){
        require(OnlyIf(msg.sender,3)==true);
        _;
    }
    //The OnlyIf Function will run in the modifier to check if the user accessing the contract is the token holder
    function OnlyIf(address _user,uint _tokenAmmount)internal view returns(bool){
        if(balanceOf(_user,0)>=_tokenAmmount){ //changed from 1 to 3 for better security
            return true;
        }else{
            return false;
        }
    }
    //This function will allow the Token Holder to view data
    function ViewData() public multi_Token view returns(string memory){
        return PrivateData;
    }
    //This function will check if current account has token
    function ViewStatus()public view returns(uint){
        return balanceOf(msg.sender,0);
    }
    //user can edit password if they hold 3 access tokens
    function Edit(string memory _newData)public multi_Token returns(bool){
         PrivateData = _newData;
         return true;
    }
    //Burn compramsed tokens
    function Burn(uint _amount, address _account)public multi_Token returns(string memory){
            _burn(_account, Token, _amount);
            return "burning {_amount} Credential tokens from {_account}";
    }
}

