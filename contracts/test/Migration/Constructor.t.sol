// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "./MigrationTest.t.sol";

contract Constructor is MigrationTest {
    function test_constructor_Normal() public {
        assertEq(migration.oldVault(), address(oldVault), "OldVault should be oldVault");
        assertEq(migration.newVault(), address(vault), "NewVault should be vault");
        assertEq(migration.asset(), address(war), "Asset should be war");
    }
}
