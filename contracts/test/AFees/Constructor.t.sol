// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "./AFeesTest.t.sol";

contract Constructor is AFeesTest {
    function test_constructor_Normal() public {
        assertEq(fees.withdrawalFee(), 150, "WithdrawalFee should be 150");
        assertEq(fees.harvestFee(), 500, "HarvestFee should be 500");
        assertEq(fees.feeRecipient(), owner, "FeeRecipient should be owner");
        assertEq(fees.feeToken(), address(feeToken), "FeeToken should be feeToken");
    }

    function test_constructor_ZeroAddressFeeRecipient() public {
        vm.expectRevert(Errors.ZeroAddress.selector);
        new AFeesMock(500, 150, address(0), address(feeToken), owner);
    }

    function test_constructor_ZeroAddressFeeToken() public {
        vm.expectRevert(Errors.ZeroAddress.selector);
        new AFeesMock(500, 150, owner, address(0), owner);
    }

    function test_constructor_InvalidHarvestFee(uint256 amount) public {
        amount = bound(amount, fees.MAX_BPS() + 1, UINT256_MAX);

        vm.expectRevert(Errors.InvalidFee.selector);
        new AFeesMock(amount, 150, owner, address(feeToken), owner);
    }

    function test_constructor_InvalidWithdrawalFee(uint256 amount) public {
        amount = bound(amount, fees.MAX_BPS() + 1, UINT256_MAX);

        vm.expectRevert(Errors.InvalidFee.selector);
        new AFeesMock(500, amount, owner, address(feeToken), owner);
    }
}
