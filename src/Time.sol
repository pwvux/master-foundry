// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Auction {
    uint256 public startAt = block.timestamp + 1 days; // Auction starts in 1 day
    uint256 public endAt = block.timestamp + 7 days; // Auction ends in 7 days

    function bid() external {
        require(block.timestamp >= startAt && block.timestamp <= endAt, "Auction is not active");
    }

    function end() external {
        require(block.timestamp > endAt, "Auction is still active");
    }
}
