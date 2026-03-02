// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {Test} from "forge-std/Test.sol";
import {Event} from "../src/Event.sol";

contract EventTest is Test {
    Event public ev;
       event Transfer(address indexed from, address indexed to, uint256 amount);

    function setUp() public {
        ev = new Event();
    }

    function testEmitTransferEvent() public {
        // expectEmit(checkTopic1, checkTopic2, checkTopic3, checkData);
        // in our case, we want to check all topics except third one , so we set checkTopic3 to false
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(this), address(0x123), 100);
        ev.transfer(address(0x123), 100);
    }

    function testEmitTransferForMany() public {
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100;
        amounts[1] = 200;
        address[] memory to = new address[](2);
        to[0] = address(0x123);
        to[1] = address(0x456);
        for(uint256 i = 0; i < to.length; i++) {
            vm.expectEmit(true, true, false, true);
            emit Transfer(address(this), to[i], amounts[i]);
        }
        ev.transferMany(to, amounts);
    }
}
