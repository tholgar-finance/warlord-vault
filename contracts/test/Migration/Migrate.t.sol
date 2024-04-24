// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "./MigrationTest.t.sol";

contract Migrate is MigrationTest {
    function setUp() public virtual override {
        super.setUp();

        deal(address(war), alice, 100e18);

        vm.startPrank(alice);
        war.approve(address(oldVault), 100e18);
        oldVault.deposit(100e18, alice);
        vm.stopPrank();
    }

    function test_migrate_Normal(uint256 amount) public {
        uint256 oldVaultBalance = oldVault.balanceOf(alice);
        uint256 vaultBalance = vault.balanceOf(alice);
        uint256 totalAssets = oldVault.totalAssets();

        amount = bound(amount, 1e18, oldVaultBalance);
        uint256 preview = oldVault.previewRedeem(amount);

        vm.startPrank(alice);
        oldVault.approve(address(migration), amount);
        migration.migrate(amount, alice, alice);
        vm.stopPrank();

        assertEq(oldVault.balanceOf(alice), oldVaultBalance - amount, "OldVault should have less balance");
        assertEq(vault.balanceOf(alice), vaultBalance + preview, "Vault should have more balance");
    }
}
