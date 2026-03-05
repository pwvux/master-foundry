// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {Test} from "forge-std/Test.sol";
import {LockedWallet} from "../src/LockedWallet.sol";

contract LockedWalletTest is Test {
    LockedWallet wallet;
    uint256 constant SECRET = 12345;

    function setUp() public {
        wallet = new LockedWallet(SECRET);
    }

    // Allow this test contract to receive ETH
    receive() external payable {}

    function testReadSecretCode() public {
        vm.load(address(wallet), bytes32(uint256(1))); // Load slot 1 where secretCode is stored
        uint256 secretCode = uint256(
            vm.load(address(wallet), bytes32(uint256(1)))
        );
        assertEq(secretCode, SECRET, "Secret code should be correct");
    }

    function testDecodeSlotZero() public {
        bytes32 slot0 = vm.load(address(wallet), bytes32(uint256(0)));
        // Decode owner and locked from slot 0
        address owner = address(uint160(uint256(slot0)));
        bool locked = (uint256(slot0) >> 160) & 1 == 1; // move 160 bits right to position 0 and check if the last bit is 1

        assertEq(owner, address(this), "Owner should be the test contract");
        assertTrue(locked, "Wallet should be locked");

        // Now set locked to false by storing 0 at bit 160
        // Keep the owner (bits 0-159) and clear bit 160
        uint256 newSlot0 = uint256(slot0) & ~(uint256(1) << 160);
        vm.store(address(wallet), bytes32(uint256(0)), bytes32(newSlot0));

        // Verify locked is now false
        bytes32 slot0After = vm.load(address(wallet), bytes32(uint256(0)));
        bool lockedAfter = (uint256(slot0After) >> 160) & 1 == 1;
        assertFalse(lockedAfter, "Wallet should be unlocked");

        // Now change the owner to an attacker address
        // Store attacker in bits 0-159, keep locked bit at position 160
        address attacker = address(0xBEEF);
        uint256 lockedBit = (uint256(slot0After) >> 160) << 160; // preserve the locked bit
        uint256 attackerSlot0 = lockedBit | uint256(uint160(attacker)); // combine locked bit with attacker address
        vm.store(address(wallet), bytes32(uint256(0)), bytes32(attackerSlot0));

        // Verify owner changed to attacker
        bytes32 slot0Final = vm.load(address(wallet), bytes32(uint256(0)));
        address ownerAfter = address(uint160(uint256(slot0Final)));
        assertEq(ownerAfter, attacker, "Owner should be changed to attacker");
    }

    function testDrainContractWithStorageManipulation() public {
        // Step 1: Fund the wallet with some ETH
        uint256 fundAmount = 10 ether;
        vm.deal(address(wallet), fundAmount);
        uint256 balanceBefore = address(wallet).balance;
        assertEq(balanceBefore, fundAmount, "Wallet should have 10 ether");

        // Step 2: Load slot 0 to get current owner and locked state
        bytes32 slot0 = vm.load(address(wallet), bytes32(uint256(0)));

        // Step 3: Unlock the wallet (set bit 160 to 0)
        uint256 newSlot0Unlocked = uint256(slot0) & ~(uint256(1) << 160);
        vm.store(
            address(wallet),
            bytes32(uint256(0)),
            bytes32(newSlot0Unlocked)
        );

        // Step 4: Verify unlock worked
        bytes32 slot0AfterUnlock = vm.load(
            address(wallet),
            bytes32(uint256(0))
        );
        bool isUnlocked = (uint256(slot0AfterUnlock) >> 160) & 1 == 0;
        assertTrue(isUnlocked, "Wallet should be unlocked");

        // Step 5: Call withdraw to drain the contract
        // This will selfdestruct and send all funds to the owner (msg.sender = address(this))
        wallet.withdraw();

        // Step 6: Verify the contract is drained
        uint256 balanceAfter = address(wallet).balance;
        assertEq(
            balanceAfter,
            0,
            "Wallet should be drained (contract destroyed)"
        );
    }
}
