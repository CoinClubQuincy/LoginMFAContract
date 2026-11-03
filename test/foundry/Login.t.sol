// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../../contracts/Public/PublicLoginContract.sol";
import "../../contracts/Private/PrivateLoginContract.sol";

contract LoginTest is Test {
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    uint factorKey = 0xA11CE;
    uint otherKey = 0xB0B;
    PublicLoginContract login;
    PublicDAppLoginContract dapp;

    function setUp() public {
        vm.prank(alice);
        login = new PublicLoginContract(vm.addr(factorKey), "uri");
        dapp = new PublicDAppLoginContract();
        dapp.Register(address(login));
    }

    function sign(uint key, address forDapp, address user) internal view returns (bytes memory) {
        bytes32 digest = ECDSA.toEthSignedMessageHash(login.loginMessage(forDapp, user));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, digest);
        return abi.encodePacked(r, s, v);
    }

    function loginAs(address user, bytes memory sig) internal returns (bool) {
        vm.prank(user);
        return dapp.userLogin(address(login), sig);
    }

    function test_ConstructorRequiresASecondFactor() public {
        vm.expectRevert("second factor is required");
        new PublicLoginContract(address(0), "uri");
    }

    function test_TokenPlusSignatureLogsIn() public {
        assertTrue(loginAs(alice, sign(factorKey, address(dapp), alice)));
        assertTrue(dapp.LoginStatus(address(login), alice));
    }

    function test_SignatureWorksOnlyOnce() public {
        bytes memory sig = sign(factorKey, address(dapp), alice);
        assertTrue(loginAs(alice, sig));
        assertFalse(loginAs(alice, sig));
        assertEq(login.nonces(alice), 1);
    }

    function test_WrongKeyFails() public {
        assertFalse(loginAs(alice, sign(otherKey, address(dapp), alice)));
        assertFalse(dapp.LoginStatus(address(login), alice));
    }

    function test_MalformedSignatureFailsWithoutReverting() public {
        assertFalse(loginAs(alice, hex"1234"));
    }

    function test_SignatureWithoutTokenFails() public {
        assertFalse(loginAs(bob, sign(factorKey, address(dapp), bob)));
        assertEq(login.nonces(bob), 0);
    }

    function test_SignatureCopiedByAnotherSenderFails() public {
        vm.prank(alice);
        login.safeTransferFrom(alice, bob, 0, 1, "");
        bytes memory sig = sign(factorKey, address(dapp), alice);
        assertFalse(loginAs(bob, sig));
        assertEq(login.nonces(alice), 0); // the real signature still works
        assertTrue(loginAs(alice, sig));
    }

    function test_SignatureForAnotherDAppFails() public {
        PublicDAppLoginContract other = new PublicDAppLoginContract();
        assertFalse(loginAs(alice, sign(factorKey, address(other), alice)));
    }

    function test_SignatureForAnotherChainFails() public {
        bytes memory sig = sign(factorKey, address(dapp), alice);
        vm.chainId(block.chainid + 1);
        assertFalse(loginAs(alice, sig));
    }

    function test_NobodyElseCanUseUpASignature() public {
        bytes memory sig = sign(factorKey, address(dapp), alice);
        vm.prank(bob);
        assertFalse(login.login(alice, sig)); // bob is not the DApp, so it does not validate
        assertEq(login.nonces(alice), 0);
    }

    function test_UserLoginChecksWithoutUsingTheSignature() public {
        bytes memory sig = sign(factorKey, address(dapp), alice);
        vm.prank(alice);
        assertTrue(login.User_Login(address(dapp), sig));
        assertEq(login.nonces(alice), 0);
        vm.prank(bob);
        vm.expectRevert("you must hold a credential token");
        login.User_Login(address(dapp), sig);
    }

    function test_UnregisteredLoginContractReverts() public {
        vm.prank(alice);
        PublicLoginContract other = new PublicLoginContract(vm.addr(factorKey), "uri");
        vm.prank(alice);
        vm.expectRevert("login contract is not registered");
        dapp.userLogin(address(other), hex"00");
    }

    function test_SessionsArePerUser() public {
        vm.prank(alice);
        login.safeTransferFrom(alice, bob, 0, 1, "");
        assertTrue(loginAs(alice, sign(factorKey, address(dapp), alice)));
        assertFalse(dapp.LoginStatus(address(login), bob));
        assertTrue(loginAs(bob, sign(factorKey, address(dapp), bob)));
        vm.prank(bob);
        dapp.Logout(address(login), bob);
        assertFalse(dapp.LoginStatus(address(login), bob));
        assertTrue(dapp.LoginStatus(address(login), alice));
    }

    function test_OnlyTheUserCanLogThemselvesOut() public {
        assertTrue(loginAs(alice, sign(factorKey, address(dapp), alice)));
        vm.prank(bob);
        vm.expectRevert("you can only log yourself out");
        dapp.Logout(address(login), alice);
    }

    function test_LosingTheTokensEndsTheSession() public {
        assertTrue(loginAs(alice, sign(factorKey, address(dapp), alice)));
        vm.prank(alice);
        login.safeTransferFrom(alice, bob, 0, 5, "");
        assertFalse(dapp.LoginStatus(address(login), alice));
    }

    function test_ASessionStaysEndedWhenTheTokensComeBack() public {
        assertTrue(loginAs(alice, sign(factorKey, address(dapp), alice)));
        vm.prank(alice);
        login.safeTransferFrom(alice, bob, 0, 5, "");
        vm.prank(bob);
        login.safeTransferFrom(bob, alice, 0, 5, "");
        assertTrue(dapp.CredToken(address(login), alice));
        assertFalse(dapp.LoginStatus(address(login), alice));

        assertTrue(loginAs(alice, sign(factorKey, address(dapp), alice)));
        assertTrue(dapp.LoginStatus(address(login), alice));
    }

    function test_MovingSomeTokensEndsTheSession() public {
        assertTrue(loginAs(alice, sign(factorKey, address(dapp), alice)));
        vm.prank(alice);
        login.safeTransferFrom(alice, bob, 0, 1, "");
        assertTrue(dapp.CredToken(address(login), alice));
        assertFalse(dapp.LoginStatus(address(login), alice));
    }

    function test_ReceivingTokensKeepsASessionAndOnlyTheSendersEnds() public {
        vm.prank(alice);
        login.safeTransferFrom(alice, bob, 0, 2, "");
        assertTrue(loginAs(bob, sign(factorKey, address(dapp), bob)));
        assertTrue(loginAs(alice, sign(factorKey, address(dapp), alice)));
        vm.prank(alice);
        login.safeTransferFrom(alice, bob, 0, 1, "");
        assertTrue(dapp.LoginStatus(address(login), bob));
        assertFalse(dapp.LoginStatus(address(login), alice));
    }

    function test_ThreeTokensAreNeededToReplaceTheSecondFactor() public {
        vm.prank(alice);
        login.safeTransferFrom(alice, bob, 0, 3, "");
        vm.prank(alice);
        vm.expectRevert("you must hold 3 credential tokens");
        login.Edit(vm.addr(otherKey));
        vm.prank(bob);
        assertTrue(login.Edit(vm.addr(otherKey)));
        assertEq(login.secondFactor(), vm.addr(otherKey));
        assertFalse(loginAs(bob, sign(factorKey, address(dapp), bob)));
        assertTrue(loginAs(bob, sign(otherKey, address(dapp), bob)));
    }

    function test_BurnCancelsStolenTokens() public {
        vm.prank(alice);
        login.safeTransferFrom(alice, bob, 0, 1, "");
        vm.prank(alice);
        login.Burn(1, bob);
        assertFalse(login.CheckUserCreds(bob));
        vm.prank(bob);
        vm.expectRevert("you must hold 3 credential tokens");
        login.Burn(1, alice);
    }

    function test_NoPasswordIsStored() public view {
        assertEq(vm.load(address(login), bytes32(uint256(3))), bytes32(uint256(uint160(vm.addr(factorKey)))));
    }

    // Private network contracts

    function privateSetup() internal returns (LoginContract p, DAppLoginContract d) {
        vm.prank(alice);
        p = new LoginContract("pw", "uri");
        d = new DAppLoginContract();
        d.Register(address(p));
    }

    function test_Private_TokenAndPasswordLogIn() public {
        (LoginContract p, DAppLoginContract d) = privateSetup();
        vm.prank(alice);
        assertTrue(d.userLogin(address(p), "pw"));
        assertTrue(d.LoginStatus(address(p), alice));
        vm.prank(alice);
        assertFalse(d.userLogin(address(p), "nope"));
    }

    function test_Private_HolderOfOneTokenCanUseUserLogin() public {
        (LoginContract p, ) = privateSetup();
        vm.prank(alice);
        p.safeTransferFrom(alice, bob, 0, 1, "");
        vm.prank(bob);
        assertTrue(p.User_Login("pw"));
    }

    function test_Private_SessionsArePerUserAndLogoutIsYourOwn() public {
        (LoginContract p, DAppLoginContract d) = privateSetup();
        vm.prank(alice);
        p.safeTransferFrom(alice, bob, 0, 1, "");
        vm.prank(alice);
        d.userLogin(address(p), "pw");
        assertFalse(d.LoginStatus(address(p), bob));
        vm.prank(bob);
        vm.expectRevert("you can only log yourself out");
        d.Logout(address(p), alice);
        vm.prank(alice);
        d.Logout(address(p), alice);
        assertFalse(d.LoginStatus(address(p), alice));
    }

    function test_Private_ASessionStaysEndedWhenTheTokensComeBack() public {
        (LoginContract p, DAppLoginContract d) = privateSetup();
        vm.prank(alice);
        assertTrue(d.userLogin(address(p), "pw"));
        assertTrue(d.LoginStatus(address(p), alice));
        vm.prank(alice);
        p.safeTransferFrom(alice, bob, 0, 5, "");
        vm.prank(bob);
        p.safeTransferFrom(bob, alice, 0, 5, "");
        assertFalse(d.LoginStatus(address(p), alice));
        vm.prank(alice);
        assertTrue(d.userLogin(address(p), "pw"));
        assertTrue(d.LoginStatus(address(p), alice));
    }

    function test_Private_ThreeTokensAreNeededToEditAndBurn() public {
        (LoginContract p, ) = privateSetup();
        vm.prank(alice);
        p.safeTransferFrom(alice, bob, 0, 3, "");
        vm.startPrank(alice);
        vm.expectRevert("you must hold 3 credential tokens");
        p.Edit("new");
        vm.expectRevert("you must hold 3 credential tokens");
        p.Burn(1, bob);
        vm.stopPrank();
        vm.prank(bob);
        assertTrue(p.Edit("new"));
        vm.prank(bob);
        assertTrue(p.User_Login("new"));
    }

    /// This is why the password variant is for private networks only.
    function test_Private_PasswordIsReadableFromStorage() public {
        (LoginContract p, ) = privateSetup();
        bytes32 slot = vm.load(address(p), bytes32(uint256(3)));
        assertEq(bytes2(slot), bytes2("pw"));
    }
}
