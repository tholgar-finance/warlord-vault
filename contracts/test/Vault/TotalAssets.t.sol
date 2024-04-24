// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "./VaultTest.t.sol";

contract TotalAssets is VaultTest {
    function test_totalAssets_Normal(uint256 amount) public {
        deal(address(staker), address(vault), amount);

        assertEqDecimal(vault.totalAssets(), amount, 18, "Total assets should be equal to the amount of staker tokens");
    }
}
