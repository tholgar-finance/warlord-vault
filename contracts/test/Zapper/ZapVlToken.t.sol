// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "./ZapperTest.t.sol";

contract ZapVlToken is ZapperTest {
    function test_zapVlToken_Normal(uint256 amount, bool tokenSeed) public {
        amount = bound(amount, 1e18, 3000e18);

        uint256 stakerBalance = staker.balanceOf(address(vault));

        address token = tokenSeed ? address(aura) : address(cvx);
        deal(address(token), alice, amount);

        uint256 expectedMintedAmount = ratios.getMintAmount(token, amount);
        uint256 expectedShares = vault.previewDeposit(expectedMintedAmount);

        vm.startPrank(alice);
        IERC20(token).approve(address(zapper), amount);
        zapper.zapVlToken(address(token), amount, alice);
        vm.stopPrank();

        assertEqDecimal(IERC20(token).balanceOf(address(zapper)), 0, 18, "Vault should have no AURA");
        assertEqDecimal(
            staker.balanceOf(address(vault)),
            stakerBalance + expectedMintedAmount,
            18,
            "Vault should have same staker balance"
        );
        assertEqDecimal(vault.balanceOf(alice), expectedShares, 18, "Alice should have expected shares");
    }

    function test_zapVlToken_ZeroValue(bool tokenSeed) public {
        address token = tokenSeed ? address(aura) : address(cvx);

        vm.prank(alice);
        vm.expectRevert(Errors.ZeroValue.selector);
        zapper.zapVlToken(address(token), 0, alice);
    }
}
