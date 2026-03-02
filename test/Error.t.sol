// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Error} from "../src/Error.sol";

contract ErrorTest is Test {
    Error public errorContract;

    function setUp() public {
        errorContract = new Error();
    }

    function testRevert() public {
        vm.expectRevert();
        errorContract.throwError();
    }

    function testCustomRevert() public {
        vm.expectRevert(Error.NotAuthorized.selector);
        errorContract.throwCustomError();
    }

    function testRevertWithRequireMessage() public {
        vm.expectRevert(bytes("not authorized"));
        errorContract.throwError();
    }
}
