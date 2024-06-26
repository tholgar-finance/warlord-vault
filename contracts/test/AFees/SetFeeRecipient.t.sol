// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "./AFeesTest.t.sol";
import { Errors } from "src/utils/Errors.sol";

contract SetFeeRecipient is AFeesTest {
    function test_setFeeRecipient_Normal(address recipient) public {
        vm.assume(recipient != address(0));

        vm.expectEmit(true, true, false, true);
        emit FeeRecipientUpdated(fees.feeRecipient(), recipient);

        vm.prank(owner);
        fees.setFeeRecipient(recipient);
        assertEq(fees.feeRecipient(), recipient, "FeeRecipient should be recipient");
    }

    function test_setFeeRecipient_NotOwner(address recipient) public {
        vm.assume(recipient != address(0));

        vm.prank(alice);
        vm.expectRevert("UNAUTHORIZED");
        fees.setFeeRecipient(recipient);
    }

    function test_setFeeRecipient_ZeroAddress() public {
        vm.expectRevert(Errors.ZeroAddress.selector);
        vm.prank(owner);
        fees.setFeeRecipient(address(0));
    }
}
