pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/// @title Credential tokens plus a second factor key, for public networks
/// @notice Nothing stored on a public chain is secret, so this contract stores no password.
/// The second factor is an address, and proving it means producing a signature with its key.
contract PublicPrivateAccessToken is ERC1155{
    address public secondFactor;
    uint Token =0;
    uint totalNFTs=5;
    event SecondFactorChanged(address _newSecondFactor);
    event CredentialsBurned(address indexed _account, uint _amount);
    // when contract is launched, the second factor & URI will be defined
    constructor(address _secondFactor,string memory URI)ERC1155(URI){
        require(_secondFactor != address(0), "second factor is required");
        secondFactor = _secondFactor;
        _mint(msg.sender, Token, totalNFTs, "");
    }
    //The modifier is so only the token holder is allowed to access function 
    modifier OnlyToken(){
        require(OnlyIf(msg.sender,1)==true, "you must hold a credential token");
        _;
    }
    // 
    modifier multi_Token(){
        require(OnlyIf(msg.sender,3)==true, "you must hold 3 credential tokens");
        _;
    }
    //The OnlyIf Function will run in the modifier to check if the user accessing the contract is the token holder
    function OnlyIf(address _user,uint _tokenAmmount)internal view returns(bool){
        if(balanceOf(_user,0)>=_tokenAmmount){
            return true;
        }else{
            return false;
        }
    }
    //This function will check if current account has token
    function ViewStatus()public view returns(uint){
        return balanceOf(msg.sender,0);
    }
    //user can replace the second factor if they hold 3 access tokens
    function Edit(address _newSecondFactor)public multi_Token returns(bool){
        require(_newSecondFactor != address(0), "second factor is required");
        secondFactor = _newSecondFactor;
        emit SecondFactorChanged(_newSecondFactor);
        return true;
    }
    //Recovery: whoever holds 3 tokens can burn credentials from any account, without its
    //consent, so stolen or compromised tokens can be cancelled
    function Burn(uint _amount, address _account)public multi_Token returns(string memory){
        _burn(_account, Token, _amount);
        emit CredentialsBurned(_account,_amount);
        return "credential tokens burned";
    }
}
