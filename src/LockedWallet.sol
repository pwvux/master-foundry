pragma solidity ^0.8.20;

contract LockedWallet {
    address private owner;         // slot 0 with 160 bits for owner 
    bool private locked;           // slot 0 (packed) // 1 bit for locked
    uint256 private secretCode;    // slot 1
    mapping(address => uint256) private allowances; // slot 2

    constructor(uint256 _code) {
        owner = msg.sender;
        locked = true;
        secretCode = _code;
    }

    function unlock(uint256 code) external {
        require(code == secretCode, "Wrong code");
        locked = false;
    }

    function withdraw() external {
        require(!locked, "Locked");
        require(msg.sender == owner, "Not owner");
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
}