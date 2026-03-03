// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Event {
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function transfer(address _to, uint256 _amount) external {
        // Emit the Transfer event
        emit Transfer(msg.sender, _to, _amount);
    }

    function transferMany(address[] calldata _to, uint256[] calldata _amounts) external {
        require(_to.length == _amounts.length, "Mismatched input lengths");
        for (uint256 i = 0; i < _to.length; i++) {
            emit Transfer(msg.sender, _to[i], _amounts[i]);
        }
    }
}
