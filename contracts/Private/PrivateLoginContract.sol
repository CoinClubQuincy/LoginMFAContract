pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./PrivateAccessToken.sol";

//interface for other contract to read status
interface LoginContract_Interface{
    function CheckUserCreds(address _user)external view returns(bool);
    function login(string memory _y)external view returns(bool);
    function sessionEpoch(address _user)external view returns(uint);
}
contract LoginContract is PrivateAccessToken,LoginContract_Interface{
    //new token that will allow for a smart contract to check credentials 
    event ContractAddress(address _ContractSelf);
    //Changes whenever a user's credential tokens move, which ends their sessions
    mapping(address => uint) public override sessionEpoch;


    //lauch Login contract with PrivateAccessToken Contract as dependancy
    constructor(string memory _Pass ,string memory _URI)PrivateAccessToken(_Pass,_URI){
        emit ContractAddress(address(this));
    }


    //I can grab the OnlyToken modifier from the Inherited contract
    function User_Login(string memory _enterPass)public view OnlyToken returns(bool){
        if(keccak256(abi.encodePacked(PrivateViewData())) == keccak256(abi.encodePacked(_enterPass))){
            return true;
        } else{
            return false;
        }
    }
    //Moving or burning any credential token ends the sender's sessions, even if the tokens come back
    function _afterTokenTransfer(address _operator,address _from,address _to,uint256[] memory _ids,uint256[] memory _amounts,bytes memory _data) internal virtual override{
        super._afterTokenTransfer(_operator,_from,_to,_ids,_amounts,_data);
        if(_from != address(0)){
            sessionEpoch[_from]++;
        }
    }
    // external source can check if user data holds correct token
    function CheckUserCreds(address _user)public view returns(bool){
        if(PrivateAccessToken.OnlyIf(_user,1) == true){
            return true;
        } else {
            return false;
        }
    }
    //Dapp Contracts can check passwords
    function login(string memory _enterPass)external view returns(bool){
        if(keccak256(abi.encodePacked(_enterPass)) == keccak256(abi.encodePacked(PrivateViewData()))){
            return true;
        }else{
            return false;
        }
    }
}
interface DAppLogin_Interface{
    function userLogin(address _LoginContract,string memory _enterPass)external returns(bool);
    function CredToken(address _LoginContract,address _user)external view returns(bool);
    function Logout(address _LoginContract,address _user)external returns(string memory);
    function LoginStatus(address _LoginContract,address _user) external view returns(bool);
    function Register(address _LoginContract)external returns(bool);
}
//DApps can have this contract be the login contract for users to use this application
contract DAppLoginContract is DAppLogin_Interface{
    uint TotalAccounts =0;
    constructor(){}
    
    //Keeps list of Login Contracts
    mapping(address => bool) registered;
    //Whether each user is logged in through each Login Contract
    mapping(address => mapping(address => bool)) sessions;
    //The login contract's session epoch for each user at the moment they logged in
    mapping(address => mapping(address => uint)) sessionEpochs;

    //User can add their login contract to this DApp so this Daap can check their credentials in reference to the logincontract
    function Register(address _LoginContract)public returns(bool){
        if(registered[_LoginContract] == true){
            return false;
        }else{
            registered[_LoginContract] = true;
            TotalAccounts++;
            return true;
        }
    }
    //Checks whether a user is logged in. Moving or losing a credential token ends the session
    function LoginStatus(address _LoginContract,address _user) public view returns(bool){
        return sessions[_LoginContract][_user]
            && sessionEpochs[_LoginContract][_user] == LoginContract_Interface(_LoginContract).sessionEpoch(_user)
            && CredToken(_LoginContract,_user);
    }
    //users log themselves out
    function Logout(address _LoginContract,address _user)public returns(string memory){
        require(msg.sender == _user, "you can only log yourself out");
        sessions[_LoginContract][_user]= false;
        return "Logged out";
    }
    //user can login and have DApp check login COntract for validity
    // contract address & password to login
    function userLogin(address _LoginContract,string memory _enterPass)public returns(bool){
        require(registered[_LoginContract]==true, "login contract is not registered");
        bool Password = LoginContract_Interface(_LoginContract).login(_enterPass);  //Has correct Password
        bool Creds = LoginContract_Interface(_LoginContract).CheckUserCreds(msg.sender); //Has correct Credential Token
        //Check Login Contract and Registration
        if(Creds==true && Password==true){
            sessions[_LoginContract][msg.sender]=true;
            sessionEpochs[_LoginContract][msg.sender]=LoginContract_Interface(_LoginContract).sessionEpoch(msg.sender);
            return true;  //user successfully logs in!
        } else{
            return false; //User fails to have correct NFT access or incorect password
        }
    }
    //check user
    function CredToken(address _LoginContract,address _user)public view returns(bool){
        return LoginContract_Interface(_LoginContract).CheckUserCreds(_user);
    }
}
//- Dev: Quincy J
