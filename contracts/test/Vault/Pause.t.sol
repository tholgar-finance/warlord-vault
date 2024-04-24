// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "./VaultTest.t.sol";

contract Pause is VaultTest {
    function test_pause_Normal() public {
        vm.prank(owner);
        vault.pause();
        assertTrue(vault.paused(), "Vault should be paused");
    }

    function test_pause_NotOwner() public {
        vm.prank(bob);
        vm.expectRevert("UNAUTHORIZED");
        vault.pause();
    }
}
