// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import { AFees, Owned2Step } from "src/abstracts/AFees.sol";

contract AFeesMock is AFees {
    constructor(
        uint256 initialHarvestFee,
        uint256 initialWithdrawalFee,
        address initialFeeRecipient,
        address initialFeeToken,
        address initialOwner
    ) Owned2Step(initialOwner) AFees(initialHarvestFee, initialWithdrawalFee, initialFeeRecipient, initialFeeToken) { }
}
