// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    Vault public vault;

    function setUp() public {
        vault = new Vault();
    }

    function testDeposit() public {
        hoax(address(1), 200);
        vault.deposit{value: 100}();
        assertEq(vault.balances(address(1)), 100);
        assertEq(address(1).balance, 100);
    }

    function testWithdraw() public {
        hoax(address(1), 200);
        vault.deposit{value: 100}();
        vm.prank(address(1));
        vault.withdraw(100);
        assertEq(vault.balances(address(1)), 0);
        assertEq(address(1).balance, 200);
    }

    function testInsufficientWithdrawBalance() public {
        hoax(address(1), 200);
        vault.deposit{value: 100}();
        vm.prank(address(1));
        vm.expectRevert(bytes("Insufficient balance"));
        vault.withdraw(200);
    }

    function testNonOwnerCall() public {
        hoax(address(1), 200);
        vault.deposit{value: 100}();
        vm.prank(address(2));
        vm.expectRevert(bytes("Not owner"));
        vault.emergencyWithdraw();
    }

    function testZeroAmountWithdraw() public {
        hoax(address(1), 200);
        vault.deposit{value: 100}();
        vm.prank(address(1));
        vault.withdraw(0);
        assertEq(vault.balances(address(1)), 100);
        assertEq(address(1).balance, 100);
    }
}
