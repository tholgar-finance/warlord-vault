// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.24;

import { Errors } from "./utils/Errors.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";
import { IMinter } from "warlord/interfaces/IMinter.sol";
import { WETH9 } from "./interfaces/external/WETH.sol";
import { Allowance } from "./utils/Allowance.sol";
import { ERC4626 } from "solady/tokens/ERC4626.sol";
import { Owned2Step } from "./utils/Owned2Step.sol";

/**
 * @title Zapper contract
 * @dev This contract enables users to seamlessly convert any token into tWAR tokens for the Warlord protocol by
 * Paladin.vote. It uses a router such as paraswap to find the routing path for the swap.
 * @author 0xtekgrinder
 */
contract Zapper is Owned2Step {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice This event is emitted when a zap operation occurs.
     * @param mintedAmount The amount of WAR tokens minted as a result.
     * @param receiver The address of the recipient of the WAR tokens.
     */
    event Zapped(uint256 mintedAmount, address receiver);
    /**
     * @notice This event is emitted when the WarMinter address is changed.
     * @param newMinter The new WarMinter address.
     */
    event SetWarMinter(address newMinter);
    /**
     * @notice This event is emitted when the WarStaker address is changed.
     * @param newStaker The new WarStaker address.
     */
    event SetWarStaker(address newStaker);
    /**
     *  @notice Event emitted when the swap router is updated
     */
    event SwapRouterUpdated(address newSwapRouter);
    /**
     *  @notice Event emitted when the token proxy is updated
     */
    event TokenTransferAddressUpdated(address newTokenTransferAddress);
    /**
     *  @notice Event emitted when the vault is updated
     */
    event VaultUpdated(address newVault);

    /*//////////////////////////////////////////////////////////////
                             CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Address of the AURA token
     */
    address public constant AURA = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;
    /**
     * @notice Address of the Convex token
     */
    address public constant CVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    /**
     * @notice Address of the WETH token
     */
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    /**
     * @notice Address of the War token
     */
    address public constant WAR = 0xa8258deE2a677874a48F5320670A869D74f0cbC1;

    /*//////////////////////////////////////////////////////////////
                          MUTABLE VARIABLES
    //////////////////////////////////////////////////////////////*/
    /**
     *  @notice Dex/aggregaor router to call to perform swaps
     */
    address public swapRouter;
    /**
     * @notice Address to allow to swap tokens
     */
    address public tokenTransferAddress;
    /**
     * @notice Address of the WarMinter contract
     */
    address public warMinter;
    /**
     * @notice Address of the ERC4626 vault
     */
    address public vault;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address initialOwner,
        address initialSwapRouter,
        address initialTokenTransferAddress,
        address initialWarMinter,
        address initialVault
    ) Owned2Step(initialOwner) {
        if (
            initialSwapRouter == address(0) || initialTokenTransferAddress == address(0)
                || initialWarMinter == address(0) || initialVault == address(0)
        ) revert Errors.ZeroAddress();

        swapRouter = initialSwapRouter;
        tokenTransferAddress = initialTokenTransferAddress;
        warMinter = initialWarMinter;
        vault = initialVault;
    }

    /*////////////////////////////////////////////
    /          Warlord allowance methods         /
    ////////////////////////////////////////////*/

    /// @dev Resets the allowances for Warlord-related interactions.
    function resetWarlordAllowances() external onlyOwner {
        SafeTransferLib.safeApprove(AURA, warMinter, type(uint256).max);
        SafeTransferLib.safeApprove(CVX, warMinter, type(uint256).max);
        SafeTransferLib.safeApprove(WAR, vault, type(uint256).max);
    }

    /// @dev Removes the allowances for Warlord-related interactions.
    function removeWarlordAllowances() external onlyOwner {
        SafeTransferLib.safeApprove(AURA, warMinter, 0);
        SafeTransferLib.safeApprove(CVX, warMinter, 0);
        SafeTransferLib.safeApprove(WAR, vault, 0);
    }

    function removeRouterAllowance(address token) external onlyOwner {
        SafeTransferLib.safeApprove(token, swapRouter, 0);
    }

    /*////////////////////////////////////////////
    /              Warlord setters               /
    ////////////////////////////////////////////*/

    /**
     * @notice Set the WarMinter address
     * @param newWarMinter address of the WarMinter
     * @custom:requires owner
     */
    function setWarMinter(address newWarMinter) external onlyOwner {
        if (newWarMinter == address(0)) revert Errors.ZeroAddress();

        warMinter = newWarMinter;

        emit SetWarMinter(newWarMinter);
    }

    /**
     * @notice Set the dex/aggregator router to call to perform swaps
     * @param newSwapRouter address of the router
     * @custom:requires owner
     */
    function setSwapRouter(address newSwapRouter) external onlyOwner {
        if (newSwapRouter == address(0)) revert Errors.ZeroAddress();

        swapRouter = newSwapRouter;

        emit SwapRouterUpdated(newSwapRouter);
    }

    /**
     * @notice Set the token proxy address to allow to swap tokens
     * @param newTokenTransferAddress address of the token proxy
     * @custom:requires owner
     */
    function setTokenTransferAddress(address newTokenTransferAddress) external onlyOwner {
        if (newTokenTransferAddress == address(0)) revert Errors.ZeroAddress();

        tokenTransferAddress = newTokenTransferAddress;

        emit TokenTransferAddressUpdated(newTokenTransferAddress);
    }

    /**
     * @notice Set the vault address
     * @param newVault address of the vault
     * @custom:requires owner
     */
    function setVault(address newVault) external onlyOwner {
        if (newVault == address(0)) revert Errors.ZeroAddress();

        vault = newVault;

        emit VaultUpdated(newVault);
    }

    /*////////////////////////////////////////////
    /                Zap Functions               /
    ////////////////////////////////////////////*/

    /**
     * @notice Perform the swap using the router/aggregator
     * @param tokens array of tokens to swap
     * @param callDatas bytes to call the router/aggregator
     */
    function _swap(address[] memory tokens, bytes[] memory callDatas) internal {
        uint256 length = tokens.length;
        for (uint256 i; i < length;) {
            address token = tokens[i];
            Allowance._approveTokenIfNeeded(token, tokenTransferAddress);
            _performRouterSwap(callDatas[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Perform the swap using the router/aggregator
     * @param callData bytes to call the router/aggregator
     */
    function _performRouterSwap(bytes memory callData) internal {
        (bool success, bytes memory retData) = swapRouter.call(callData);

        if (!success) {
            if (retData.length != 0) {
                assembly {
                    revert(add(32, retData), mload(retData))
                }
            }
            revert Errors.SwapError();
        }
    }

    /**
     * @notice Mint a single vlToken
     * @param receiver Address to stake for
     * @param vlToken Token to mint WAR
     * @param amount Amount of token to mint
     */
    function _mintSingleToken(address receiver, address vlToken, uint256 amount) internal {
        IMinter(warMinter).mint(vlToken, amount);
        uint256 stakedAmount = ERC20(WAR).balanceOf(address(this));
        ERC4626(vault).deposit(stakedAmount, receiver);

        emit Zapped(stakedAmount, receiver);
    }

    /**
     * @notice Swap to a single vlToken and mint tWAR
     * @param receiver Address to stake for
     * @param token Token to swap
     * @param vlToken Token to mint WAR
     * @param callDatas bytes to call the router/aggregator
     */
    function _swapAndMintSingleToken(address receiver, address token, address vlToken, bytes memory callDatas)
        internal
    {
        address[] memory tokens = new address[](1);
        tokens[0] = token;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = callDatas;

        // Swap tokens and mint tWAR
        _swap(tokens, calldatas);
        uint256 amount = ERC20(vlToken).balanceOf(address(this));
        _mintSingleToken(receiver, vlToken, amount);
    }

    /**
     * @notice Mint multiple vlTokens
     * @param receiver Address to stake for
     * @param vlTokens Tokens to mint WAR
     * @param amounts Amounts to mint
     */
    function _mintMultipleTokens(address receiver, address[] memory vlTokens, uint256[] memory amounts) internal {
        uint256 length = vlTokens.length;
        for (uint256 i; i < length;) {
            IMinter(warMinter).mint(vlTokens[i], amounts[i]);
            unchecked {
                ++i;
            }
        }
        uint256 stakedAmount = ERC20(WAR).balanceOf(address(this));
        ERC4626(vault).deposit(stakedAmount, receiver);

        emit Zapped(stakedAmount, receiver);
    }

    /**
     * @notice Swap to multiple vlTokens and mint tWAR
     * @param receiver Address to stake for
     * @param token Token to swap
     * @param vlTokens Tokens to mint WAR
     * @param callDatas bytes to call the router/aggregator
     */
    function _swapAndMintMultipleTokens(
        address receiver,
        address token,
        address[] memory vlTokens,
        bytes[] memory callDatas
    ) internal {
        // Create an array of the same token
        uint256 length = callDatas.length;
        address[] memory tokens = new address[](length);
        for (uint256 i; i < length;) {
            tokens[i] = token;
            unchecked {
                ++i;
            }
        }

        // Swap tokens and mint tWAR
        _swap(tokens, callDatas);

        length = vlTokens.length;
        uint256[] memory amounts = new uint256[](length);
        for (uint256 i; i < length;) {
            amounts[i] = ERC20(vlTokens[i]).balanceOf(address(this));
            unchecked {
                ++i;
            }
        }
        _mintMultipleTokens(receiver, vlTokens, amounts);
    }

    /**
     * @notice Zaps ether to a single vlToken
     * @param receiver Address to stake for
     * @param vlToken Token to mint WAR
     * @param callDatas bytes to call the router/aggregator
     */
    function zapEtherToSingleToken(address vlToken, address receiver, bytes calldata callDatas) external payable {
        if (receiver == address(0)) revert Errors.ZeroAddress();
        if (msg.value == 0) revert Errors.ZeroValue();

        // Convert native eth to weth
        WETH9(WETH).deposit{ value: msg.value }();

        _swapAndMintSingleToken(receiver, WETH, vlToken, callDatas);
    }

    /**
     * @notice Zaps an ERC20 token to a single vlToken
     * @param token Token to swap
     * @param vlToken Token to mint WAR
     * @param amount Amount of token to swap
     * @param receiver Address to stake for
     * @param callDatas bytes to call the router/aggregator
     */
    function zapERC20ToSingleToken(
        address token,
        address vlToken,
        uint256 amount,
        address receiver,
        bytes calldata callDatas
    ) external {
        if (token == address(0)) revert Errors.ZeroAddress();
        if (receiver == address(0)) revert Errors.ZeroAddress();
        if (amount == 0) revert Errors.ZeroValue();

        // Pull ERC20 from sender to this contract
        SafeTransferLib.safeTransferFrom(token, msg.sender, address(this), amount);

        _swapAndMintSingleToken(receiver, token, vlToken, callDatas);
    }

    /**
     * @notice Zaps ether to multiple vlTokens
     * @param receiver Address to stake for
     * @param vlTokens List of token addresses to deposit
     * @param callDatas bytes to call the router/aggregator
     */
    function zapEtherToMultipleTokens(address[] calldata vlTokens, address receiver, bytes[] calldata callDatas)
        external
        payable
    {
        if (receiver == address(0)) revert Errors.ZeroAddress();
        if (msg.value == 0) revert Errors.ZeroValue();

        // Convert native eth to weth
        WETH9(WETH).deposit{ value: msg.value }();

        _swapAndMintMultipleTokens(receiver, WETH, vlTokens, callDatas);
    }

    /**
     * @notice Zaps an ERC20 token to multiple vlTokens
     * @param token Token to swap
     * @param amount Amount of token to swap
     * @param receiver Address to stake for
     * @param vlTokens List of token addresses to deposit
     * @param callDatas bytes to call the router/aggregator
     */
    function zapERC20ToMultipleTokens(
        address token,
        address[] calldata vlTokens,
        uint256 amount,
        address receiver,
        bytes[] calldata callDatas
    ) external {
        if (receiver == address(0)) revert Errors.ZeroAddress();
        if (amount == 0) revert Errors.ZeroValue();

        // Pull ERC20 from sender to this contract
        SafeTransferLib.safeTransferFrom(token, msg.sender, address(this), amount);

        _swapAndMintMultipleTokens(receiver, token, vlTokens, callDatas);
    }

    /**
     * @notice Zaps a vlToken to tWAR
     * @param vlToken Token to mint WAR
     * @param amount Amount of token to swap
     * @param receiver Address to stake for
     */
    function zapVlToken(address vlToken, uint256 amount, address receiver) external {
        if (vlToken == address(0)) revert Errors.ZeroAddress();
        if (receiver == address(0)) revert Errors.ZeroAddress();
        if (amount == 0) revert Errors.ZeroValue();

        // Pull vl token from sender to this contract
        SafeTransferLib.safeTransferFrom(vlToken, msg.sender, address(this), amount);

        _mintSingleToken(receiver, vlToken, amount);
    }

    /**
     * @notice Zaps multiple vlTokens to tWAR
     * @param vlTokens List of token addresses to deposit
     * @param amounts List of token amounts to deposit
     * @param receiver Address to stake for
     */
    function zapVlTokens(address[] calldata vlTokens, uint256[] calldata amounts, address receiver) external {
        if (receiver == address(0)) revert Errors.ZeroAddress();

        // Pull vl tokens from sender to this contract
        uint256 length = vlTokens.length;
        for (uint256 i; i < length;) {
            if (amounts[i] == 0) revert Errors.ZeroValue();
            SafeTransferLib.safeTransferFrom(vlTokens[i], msg.sender, address(this), amounts[i]);
            unchecked {
                ++i;
            }
        }

        _mintMultipleTokens(receiver, vlTokens, amounts);
    }
}
