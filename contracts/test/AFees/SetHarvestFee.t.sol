// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "./AFeesTest.t.sol";

contract SetHarvestFee is AFeesTest {
    function test_setHarvestFee_Normal(uint256 amount) public {
        amount = bound(amount, 0, fees.MAX_HARVEST_FEE());

        vm.expectEmit(true, true, false, true);
        emit HarvestFeeUpdated(fees.harvestFee(), amount);

        vm.prank(owner);
        fees.setHarvestFee(amount);
        assertEq(fees.harvestFee(), amount, "HarvestFee should be amount");
    }

    function test_setHarvestFee_NotOwner(uint256 amount) public {
        amount = bound(amount, 0, fees.MAX_HARVEST_FEE());

        vm.prank(alice);
        vm.expectRevert("UNAUTHORIZED");
        fees.setHarvestFee(amount);
    }

    function test_setHarvestFee_InvalidFee(uint256 amount) public {
        amount = bound(amount, fees.MAX_HARVEST_FEE() + 1, UINT256_MAX);

        vm.expectRevert(Errors.InvalidFee.selector);
        vm.prank(owner);
        fees.setHarvestFee(amount);
    }
}
