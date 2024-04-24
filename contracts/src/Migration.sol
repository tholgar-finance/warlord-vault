// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.24;

import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { ERC4626 } from "solady/tokens/ERC4626.sol";

/// @author 0xtekgrinder
/// @title Migration contract
/// @notice This contract migrates assets from an old vault to a new vault
contract Migration {
    /*//////////////////////////////////////////////////////////////
                          CONSTANTS VARIABLES
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Address of the old vault
     */
    address public immutable oldVault;
    /**
     * @notice Address of the new vault
     */
    address public immutable newVault;
    /**
     * @notice Address of the asset to be migrated
     */
    address public immutable asset;

    /*//////////////////////////////////////////////////////////////
                             CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address definitiveOldVault, address definitiveNewVault, address definitiveAsset) {
        oldVault = definitiveOldVault;
        newVault = definitiveNewVault;
        asset = definitiveAsset;

        SafeTransferLib.safeApprove(asset, newVault, type(uint256).max);
    }

    function migrate(uint256 amount, address owner, address receiver) public {
        // Redeem the amount from the old vault into WAR
        uint256 assets = ERC4626(oldVault).redeem(amount, address(this), owner);

        // Deposit the amount into the new vault
        ERC4626(newVault).deposit(assets, receiver);
    }
}
