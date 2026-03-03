// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Vault {
    mapping(address => uint256) public balances;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
    // @audit There is no check for zero amount
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
    // @audit the owner can drain everyone's deposit
    function emergencyWithdraw() external {
        require(msg.sender == owner, "Not owner");
        (bool success,) = owner.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
}
