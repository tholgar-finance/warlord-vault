//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";

library Allowance {
    /**
     * @notice Approve the router/aggregator to spend the token if needed
     * @param _token address of the token to approve
     * @param _spender address of the router/aggregator
     */
    function _approveTokenIfNeeded(address _token, address _spender) internal {
        if (ERC20(_token).allowance(address(this), _spender) == 0) {
            SafeTransferLib.safeApprove(_token, _spender, type(uint256).max);
        }
    }
}
