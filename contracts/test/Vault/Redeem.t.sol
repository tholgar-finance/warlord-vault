// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "./VaultTest.t.sol";

contract Redeem is VaultTest {
    function test_redeem_Paused() public {
        vm.startPrank(owner);
        vault.pause();
        vm.expectRevert(Pausable.EnforcedPause.selector);
        vault.redeem(1, alice, alice);
        vm.stopPrank();
    }

    function test_redeem_ZeroAssets() public {
        vm.startPrank(alice);
        vm.expectRevert(Errors.ZeroValue.selector);
        vault.redeem(0, alice, alice);
        vm.stopPrank();
    }

    function test_redeem_Normal(uint256 amount, address pranker) public {
        amount = bound(amount, 1e18, 1000e18);
        vm.assume(pranker != address(0));
        vm.assume(pranker != owner);

        deal(address(war), pranker, amount);

        vm.startPrank(pranker);
        war.approve(address(vault), amount);
        uint256 shares = vault.deposit(amount, pranker);

        uint256 assets = vault.redeem(shares, pranker, pranker);
        vm.stopPrank();

        assertEqDecimal(IERC20(vault.asset()).balanceOf(pranker), assets, 18, "Pranker should have received assets");
        assertEqDecimal(
            staker.balanceOf(address(vault)),
            amount - (amount * (vault.MAX_BPS() - vault.withdrawalFee()) / vault.MAX_BPS()),
            18,
            "Staker should have received staking tokens"
        );
        assertEqDecimal(vault.balanceOf(pranker), 0, 18, "Pranker should have no shares");
        assertEqDecimal(
            vault.totalAssets(),
            amount - (amount * (vault.MAX_BPS() - vault.withdrawalFee()) / vault.MAX_BPS()),
            18,
            "Total assets should have decreased"
        );
    }
}
