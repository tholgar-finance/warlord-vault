// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.24;

import { Owned2Step } from "../utils/Owned2Step.sol";
import { Errors } from "../utils/Errors.sol";

/// @author 0xtekgrinder
/// @title AFees
/// @notice Abstract contract to allow access only to operator or owner
abstract contract AFees is Owned2Step {
    /*//////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when harvestFee is updated
     */
    event HarvestFeeUpdated(uint256 oldHarvestFee, uint256 newHarvestFee);
    /**
     * @notice Event emitted when feeRecipient is updated
     */
    event FeeRecipientUpdated(address oldFeeRecipient, address newFeeRecipient);
    /**
     * @notice Event emitted when feeToken is updated
     */
    event FeeTokenUpdated(address oldFeeToken, address newFeeToken);
    /**
     * @notice Event emitted when withdrawalFee is updated
     */
    event WithdrawalFeeUpdated(uint256 oldWithdrawalFee, uint256 newWithdrawalFee);

    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Max BPS value (100%)
     */
    uint256 public constant MAX_BPS = 10_000;
    /**
     * @notice Max withdrawal fee value (10%)
     */
    uint256 public constant MAX_WITHDRAWAL_FEE = 1000;
    /**
     * @notice Max harvest fee value (20%)
     */
    uint256 public constant MAX_HARVEST_FEE = 2000;

    /*//////////////////////////////////////////////////////////////
                            MUTABLE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice fee to be applied when harvesting rewards
     */
    uint256 public harvestFee;
    /**
     * @notice fee to be applied when withdrawing funds
     */
    uint256 public withdrawalFee;
    /**
     * @notice address to receive the harvest fee
     */
    address public feeRecipient;
    /**
     * @notice token to be used to pay the harvest fee
     */
    address public feeToken;

    /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        uint256 initialHarvestFee,
        uint256 initialWithdrawalFee,
        address initialFeeRecipient,
        address initialFeeToken
    ) {
        if (initialFeeRecipient == address(0) || initialFeeToken == address(0)) revert Errors.ZeroAddress();
        if (initialHarvestFee > MAX_HARVEST_FEE || initialWithdrawalFee > MAX_WITHDRAWAL_FEE) {
            revert Errors.InvalidFee();
        }

        harvestFee = initialHarvestFee;
        feeRecipient = initialFeeRecipient;
        feeToken = initialFeeToken;
        withdrawalFee = initialWithdrawalFee;
    }

    /*//////////////////////////////////////////////////////////////
                              FEES LOGIC
    //////////////////////////////////////////////////////////////*/

    function setHarvestFee(uint256 newHarvestFee) external virtual onlyOwner {
        if (newHarvestFee > MAX_HARVEST_FEE) {
            revert Errors.InvalidFee();
        }

        uint256 oldHarvestFee = harvestFee;
        harvestFee = newHarvestFee;

        emit HarvestFeeUpdated(oldHarvestFee, newHarvestFee);
    }

    function setWithdrawalFee(uint256 newWithdrawalFee) external virtual onlyOwner {
        if (newWithdrawalFee > MAX_WITHDRAWAL_FEE) {
            revert Errors.InvalidFee();
        }

        uint256 oldWithdrawalFee = withdrawalFee;
        withdrawalFee = newWithdrawalFee;

        emit WithdrawalFeeUpdated(oldWithdrawalFee, newWithdrawalFee);
    }

    function setFeeRecipient(address newFeeRecipient) external virtual onlyOwner {
        if (newFeeRecipient == address(0)) revert Errors.ZeroAddress();

        address oldFeeRecipient = feeRecipient;
        feeRecipient = newFeeRecipient;

        emit FeeRecipientUpdated(oldFeeRecipient, newFeeRecipient);
    }

    function setFeeToken(address newFeeToken) external virtual onlyOwner {
        if (newFeeToken == address(0)) revert Errors.ZeroAddress();

        address oldFeeToken = feeToken;
        feeToken = newFeeToken;

        emit FeeTokenUpdated(oldFeeToken, newFeeToken);
    }
}
