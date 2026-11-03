pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../Public/PublicPrivateAccessToken.sol";

//interface for other contract to read status
interface PublicLoginContract_Interface{
    function CheckUserCreds(address _user)external view returns(bool);
    function login(address _user,bytes memory _signature)external returns(bool);
}
/// @notice A login needs a credential token and a signature from the second factor key. The
/// signature names this contract, the DApp, the user, a nonce and the chain, so it works once,
/// for that user at that DApp. Copying it from a pending transaction gains nothing, because a
/// different sender makes it invalid.
contract PublicLoginContract is PublicPrivateAccessToken,PublicLoginContract_Interface{
    using ECDSA for bytes32;

    //new token that will allow for a smart contract to check credentials 
    event ContractAddress(address _ContractSelf);
    //How many logins each user has made, which makes each signature single-use
    mapping(address => uint) public nonces;

    //lauch Login contract with PrivateAccessToken Contract as dependancy
    constructor(address _secondFactor ,string memory _URI)PublicPrivateAccessToken(_secondFactor,_URI){
        emit ContractAddress(address(this));
    }
    /// @notice The hash the second factor key signs, with eth_sign / personal_sign
    function loginMessage(address _dapp,address _user) public view returns(bytes32){
        return keccak256(abi.encode(address(this),_dapp,_user,nonces[_user],block.chainid));
    }
    function validSignature(address _dapp,address _user,bytes memory _signature) internal view returns(bool){
        (address signer, ECDSA.RecoverError error) = loginMessage(_dapp,_user).toEthSignedMessageHash().tryRecover(_signature);
        return error == ECDSA.RecoverError.NoError && signer == secondFactor;
    }
    //Token holders can test a signature for a DApp without using it up
    function User_Login(address _dapp,bytes memory _signature)public view OnlyToken returns(bool){
        return validSignature(_dapp,msg.sender,_signature);
    }
    // external source can check if user data holds correct token
    function CheckUserCreds(address _user)public view returns(bool){
        if(PublicPrivateAccessToken.OnlyIf(_user,1) == true){
            return true;
        } else {
            return false;
        }
    }
    //Dapp Contracts check the second factor here. The DApp must be the caller, so nobody else
    //can use up a signature meant for it.
    function login(address _user,bytes memory _signature)external returns(bool){
        if(validSignature(msg.sender,_user,_signature) == false){
            return false;
        }
        nonces[_user]++;
        return true;
    }
}
interface PublicDAppLogin_Interface{
    function userLogin(address _LoginContract,bytes memory _signature)external returns(bool);
    function CredToken(address _LoginContract,address _user)external view returns(bool);
    function Logout(address _LoginContract,address _user)external returns(string memory);
    function LoginStatus(address _LoginContract,address _user) external view returns(bool);
    function Register(address _LoginContract)external returns(bool);
}
/// @notice DApps can have this contract be the login contract for users to use this application.
/// A login proves control of the named login contract. Anyone can deploy their own, so trust
/// comes from which login contract you recognise, not from a login succeeding.
contract PublicDAppLoginContract is PublicDAppLogin_Interface{
    uint TotalAccounts =0;
    constructor(){}

    //Keeps list of Login Contracts
    mapping(address => bool) registered;
    //Whether each user is logged in through each Login Contract
    mapping(address => mapping(address => bool)) sessions;

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
    //Checks whether a user is logged in. Losing the credential token ends the session
    function LoginStatus(address _LoginContract,address _user) public view returns(bool){
        return sessions[_LoginContract][_user] && CredToken(_LoginContract,_user);
    }
    //users log themselves out
    function Logout(address _LoginContract,address _user)public returns(string memory){
        require(msg.sender == _user, "you can only log yourself out");
        sessions[_LoginContract][_user]= false;
        return "Logged out";
    }
    //user can login and have DApp check login COntract for validity
    function userLogin(address _LoginContract,bytes memory _signature)public returns(bool){
        require(registered[_LoginContract]==true, "login contract is not registered");
        //Has correct Credential Token. Checked first so a failed login uses up no signature
        if(CredToken(_LoginContract,msg.sender) == false){
            return false;
        }
        //Has a signature from the second factor
        if(PublicLoginContract_Interface(_LoginContract).login(msg.sender,_signature) == false){
            return false;
        }
        sessions[_LoginContract][msg.sender]=true;
        return true;
    }
    //check user
    function CredToken(address _LoginContract,address _user)public view returns(bool){
        return PublicLoginContract_Interface(_LoginContract).CheckUserCreds(_user);
    }
}
//- Dev: Quincy J
