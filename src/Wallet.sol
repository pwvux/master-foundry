// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Wallet {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function _onlyOwner() internal {
        require(msg.sender == owner, "Only the owner can call this function");
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    receive() external payable {}

    function withdraw(uint _amount) public {
        require(msg.sender == owner, "Only the owner can withdraw funds");
        payable(msg.sender).transfer(_amount);
    }

    function setOwner(address _newOwner) public onlyOwner {
        owner = payable(_newOwner);
    }
}
