// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "./AFeesTest.t.sol";

contract SetWithdrawalFee is AFeesTest {
    function test_setWithdrawalFee_Normal(uint256 amount) public {
        amount = bound(amount, 0, fees.MAX_WITHDRAWAL_FEE());

        vm.expectEmit(true, true, false, true);
        emit AFees.WithdrawalFeeUpdated(fees.withdrawalFee(), amount);

        vm.prank(owner);
        fees.setWithdrawalFee(amount);
        assertEq(fees.withdrawalFee(), amount, "WithdrawalFee should be amount");
    }

    function test_setWithdrawalFee_NotOwner(uint256 amount) public {
        amount = bound(amount, 0, fees.MAX_WITHDRAWAL_FEE());

        vm.prank(alice);
        vm.expectRevert("UNAUTHORIZED");
        fees.setWithdrawalFee(amount);
    }

    function test_setWithdrawalFee_InvalidFee(uint256 amount) public {
        amount = bound(amount, fees.MAX_WITHDRAWAL_FEE() + 1, UINT256_MAX);

        vm.expectRevert(Errors.InvalidFee.selector);
        vm.prank(owner);
        fees.setWithdrawalFee(amount);
    }
}
