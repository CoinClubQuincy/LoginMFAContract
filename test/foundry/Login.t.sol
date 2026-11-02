// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../../contracts/Public/PublicLoginContract.sol";

contract LoginTest is Test {
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    PublicLoginContract login;
    PublicDAppLoginContract dapp;

    function setUp() public {
        vm.prank(alice);
        login = new PublicLoginContract("pw", "uri");
        dapp = new PublicDAppLoginContract();
        dapp.Register(address(login));
    }

    function hashed(string memory s) internal pure returns (string memory) {
        return string(abi.encodePacked(keccak256(abi.encodePacked(s))));
    }

    function test_TokenPlusHashedPasswordLogsIn() public {
        vm.prank(alice);
        assertTrue(dapp.userLogin(address(login), hashed("pw")));
        assertTrue(dapp.LoginStatus(address(login)));
    }

    function test_PlainPasswordIsRejectedByTheDAppPath() public {
        vm.prank(alice);
        assertFalse(dapp.userLogin(address(login), "pw"));
    }

    function test_CorrectPasswordWithoutTokenFails() public {
        vm.prank(bob);
        assertFalse(dapp.userLogin(address(login), hashed("pw")));
    }

    function test_WrongPasswordFails() public {
        vm.prank(alice);
        assertFalse(dapp.userLogin(address(login), hashed("nope")));
    }

    function test_UnregisteredLoginContractReverts() public {
        vm.prank(alice);
        PublicLoginContract other = new PublicLoginContract("pw", "uri");
        vm.prank(alice);
        vm.expectRevert();
        dapp.userLogin(address(other), hashed("pw"));
    }

    function test_ThreeTokensAreNeededToChangeThePassword() public {
        vm.prank(alice);
        login.safeTransferFrom(alice, bob, 0, 2, "");
        vm.prank(bob);
        vm.expectRevert();
        login.Edit("new");
        vm.prank(alice);
        assertTrue(login.Edit("new"));
    }

    /// The stored hash is exactly what login() expects, so on a public chain the password
    /// factor is not secret. The credential token is the only factor left.
    function test_StoredHashAloneBeatsThePasswordCheck() public view {
        bytes32 stored = vm.load(address(login), bytes32(uint256(3)));
        assertTrue(login.login(string(abi.encodePacked(stored))));
    }
}
