// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "./ZapperTest.t.sol";

contract ZapVlTokens is ZapperTest {
    function test_zapVlTokens_Normal(uint256[2] memory tokenAmount) public {
        uint256[] memory tokenAmounts = new uint256[](2);
        tokenAmounts[0] = bound(tokenAmount[0], 1e18, 3000e18);
        tokenAmounts[1] = bound(tokenAmount[1], 1e18, 3000e18);

        address[] memory tokens = new address[](2);
        tokens[0] = address(aura);
        tokens[1] = address(cvx);

        uint256 stakerBalance = staker.balanceOf(address(vault));

        deal(address(aura), alice, tokenAmounts[0]);
        deal(address(cvx), alice, tokenAmounts[1]);

        uint256 expectedMintedAmount =
            ratios.getMintAmount(address(aura), tokenAmounts[0]) + ratios.getMintAmount(address(cvx), tokenAmounts[1]);
        uint256 expectedShares = vault.previewDeposit(expectedMintedAmount);

        vm.startPrank(alice);

        IERC20(tokens[0]).approve(address(zapper), tokenAmounts[0]);
        IERC20(tokens[1]).approve(address(zapper), tokenAmounts[1]);
        zapper.zapVlTokens(tokens, tokenAmounts, alice);

        vm.stopPrank();

        assertEqDecimal(aura.balanceOf(address(zapper)), 0, 18, "Vault should have no AURA");
        assertEqDecimal(cvx.balanceOf(address(zapper)), 0, 18, "Vault should have no CVX");
        assertEqDecimal(
            staker.balanceOf(address(vault)),
            stakerBalance + expectedMintedAmount,
            18,
            "Vault should have same staker balance"
        );
        assertEqDecimal(vault.balanceOf(alice), expectedShares, 18, "Alice should have expected shares");
    }

    function test_zapVlTokens_ZeroValue() public {
        address[] memory tokens = new address[](2);
        tokens[0] = address(aura);
        tokens[1] = address(cvx);
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 0;
        amounts[1] = 0;

        vm.prank(alice);
        vm.expectRevert(Errors.ZeroValue.selector);
        zapper.zapVlTokens(tokens, amounts, alice);
    }
}
