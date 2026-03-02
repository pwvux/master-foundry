// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {Test} from "forge-std/Test.sol";
import {Wallet} from "../src/Wallet.sol";

contract WalletTest is Test {
    Wallet public wallet;

    function setUp() public {
        wallet = new Wallet();
    }

    function testOwner() public {
        assertEq(wallet.owner(), address(this));
    }

    function test_RevertIfWhenNotOwner() public {
        vm.startPrank(address(0x123));
        address newOwner = address(0x456);
        vm.expectRevert();
        wallet.setOwner(newOwner);
        vm.stopPrank();
    }
}
