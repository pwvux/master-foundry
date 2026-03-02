// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {Test, console} from "forge-std/Test.sol";
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

    function testEthBalance() public {
        console.log("Initial balance:", address(this).balance / 1e18);
    }

    function _send(uint256 _amount) internal {
        (bool success, ) = address(wallet).call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    function testSendEth() public {
        hoax(address(1), 10 ether); // deal + prank in one step
        _send(1 ether);
        console.log("Balance after sending:", address(wallet).balance / 1e18);
        assertEq(address(wallet).balance, 1 ether);
        assertEq(address(1).balance, 9 ether);
    }
}
