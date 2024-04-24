// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "./VaultTest.t.sol";

contract Unpause is VaultTest {
    function test_unpause_Normal() public {
        vm.startPrank(owner);
        vault.pause();
        vault.unpause();
        vm.stopPrank();
        assertFalse(vault.paused(), "Vault should be unpaused");
    }

    function test_unpause_NotOwner() public {
        vm.prank(bob);
        vm.expectRevert("UNAUTHORIZED");
        vault.unpause();
    }
}
