// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {Test} from "forge-std/Test.sol";
import {Auction} from "../src/Time.sol";

contract TimeTest is Test {
    Auction public auction;
    uint256 public startAt;

    function setUp() public {
        auction = new Auction();
        startAt = block.timestamp;
    }

    function testBidFailsBeforeStartTime() public {
        vm.expectRevert("Auction is not active");
        auction.bid();
    }

    function testBidSucceedsDuringAuction() public {
        // Fast forward time to the start of the auction
        vm.warp(startAt + 1 days);
        auction.bid(); // Should not revert
    }

    function testBidFailedAfterEndTime() public {
        // Fast forward time to after the end of the auction
        vm.warp(startAt + 8 days); // 7 days start auction + 1 day buffer
        vm.expectRevert("Auction is not active");
        auction.bid();
    }

    function testEndBidFailedBeforeEndTime() public {
        // Fast forward time to the start of the auction
        vm.warp(startAt + 2 days);
        vm.expectRevert("Auction is still active");
        auction.end();
    }

    function testTimestamp() public {
        uint256 t = block.timestamp;
        // set block.timestamp to t + 100
        skip(100);
        assertEq(block.timestamp, t + 100);

        // set block.timestamp to t + 100 - 100;
        rewind(100);
        assertEq(block.timestamp, t);
    }

    function testBlockNumber() public {
        uint256 b = block.number;
        // set block number to 11
        vm.roll(11);
        assertEq(block.number, 11);
    }
}
