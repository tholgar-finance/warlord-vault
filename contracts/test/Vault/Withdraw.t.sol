// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "./VaultTest.t.sol";

contract Withdraw is VaultTest {
    function test_withdraw_Paused() public {
        vm.prank(owner);
        vault.pause();
        vm.expectRevert(Pausable.EnforcedPause.selector);
        vault.withdraw(0, owner, owner);
    }

    function test_withdraw_Normal(uint256 amount, address pranker) public {
        amount = bound(amount, 1e18, 1000e18);
        vm.assume(pranker != address(0));
        vm.assume(pranker != owner);

        deal(address(war), pranker, amount);

        vm.startPrank(pranker);
        war.approve(address(vault), amount);
        uint256 shares = vault.deposit(amount, pranker);

        uint256 sharesWithdrawn = vault.withdraw(amount, pranker, pranker);
        vm.stopPrank();

        assertEqDecimal(sharesWithdrawn, shares, 18, "Pranker should have withdrawn all shares");
        assertEqDecimal(
            IERC20(vault.asset()).balanceOf(pranker),
            amount * (vault.MAX_BPS() - vault.withdrawalFee()) / vault.MAX_BPS(),
            18,
            "Pranker should have received assets"
        );
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
