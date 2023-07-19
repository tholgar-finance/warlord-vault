// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.20;

import {Pausable} from "openzeppelin-contracts/security/Pausable.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {IMinter} from "warlord/interfaces/IMinter.sol";
import {IStaker} from "warlord/interfaces/IStaker.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {ISwapper} from "./interfaces/ISwapper.sol";
import {AWeightedTokens} from "./abstracts/AWeightedTokens.sol";
import {AOperator} from "./abstracts/AOperator.sol";
import {AFees} from "./abstracts/AFees.sol";
import {Errors} from "./utils/Errors.sol";
import {Allowance} from "./utils/Allowance.sol";

/// @author 0xtekgrinder
/// @title Vault contract
/// @notice Auto compounding vault for the warlord protocol with token to deposit being WAR and asset being stkWAR
contract Vault is ERC4626, Pausable, ReentrancyGuard, AFees, AOperator, AWeightedTokens {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when a staker is updated
     */
    event StakerUpdated(address oldStaker, address newStaker);
    /**
     * @notice Event emitted when a minter is updated
     */
    event MinterUpdated(address oldMinter, address newMinter);
    /**
     * @notice Event emitted when a token is added to the list of tokens to harvest
     */
    event TokenNotToHarvestUpdated(address token, bool harvestOrNot);
    /**
     * @notice Event emitted when a swapper is updated
     */
    event SwapperUpdated(address oldSwapper, address newSwapper);

    /**
     * @notice Event emitted when reward have been harvested
     */
    event Harvested(uint256 amount);
    /**
     * @notice Event emitted when rewards are compounded into more stkWAR
     */
    event Compounded(uint256 amount);

    /*//////////////////////////////////////////////////////////////
                          MUTABLE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Address of the stkWAR token
     */
    address public staker;
    /**
     *  @notice Address of the WAR minter contract
     */
    address public minter;
    /**
     * @notice Address of the swapper contract
     */
    address public swapper;

    /**
     * @notice mapping to keep track of which tokens to harvest
     */
    mapping(address token => bool harvestOrNot) public tokensNotToHarvest;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address initialStaker,
        address initialMinter,
        address initialSwapper,
        uint256 initialHarvestFee,
        address initialFeeRecipient,
        address initialFeeToken,
        address initialOperator,
        address definitiveAsset
    )
        ERC4626(ERC20(definitiveAsset), "wstkWARToken", "wstkWAR")
        AFees(initialHarvestFee, initialFeeRecipient, initialFeeToken)
        AOperator(initialOperator)
    {
        if (initialStaker == address(0) || initialMinter == address(0) || initialSwapper == address(0)) {
            revert Errors.ZeroAddress();
        }

        staker = initialStaker;
        minter = initialMinter;
        swapper = initialSwapper;

        ERC20(definitiveAsset).safeApprove(initialStaker, type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice update the staker contract to a new one
     * @param newStaker the new staker contract
     * @custom:requires owner
     */
    function setStaker(address newStaker) external onlyOwner {
        if (newStaker == address(0)) revert Errors.ZeroAddress();
        address oldStaker = staker;

        staker = newStaker;
        emit StakerUpdated(oldStaker, newStaker);

        // Unstake all wars from old staker
        uint256 stakerBalance = ERC20(oldStaker).balanceOf(address(this));
        if (stakerBalance != 0) {
            IStaker(oldStaker).unstake(stakerBalance, address(this));
        }
        // revoke allowance from old staker
        ERC20(address(asset)).safeApprove(oldStaker, 0);

        // approve all war tokens to be spent by new staker
        ERC20(address(asset)).safeApprove(newStaker, type(uint256).max);

        // Restake all tokens
        uint256 warBalance = asset.balanceOf(address(this));
        if (warBalance != 0) {
            IStaker(newStaker).stake(warBalance, address(this));
        }
    }

    /**
     * @notice update the swapper contract to a new one
     * @param newSwapper the new swapper contract
     * @custom:requires owner
     */
    function setSwapper(address newSwapper) external onlyOwner {
        if (newSwapper == address(0)) revert Errors.ZeroAddress();

        address oldSwapper = swapper;
        swapper = newSwapper;

        emit SwapperUpdated(oldSwapper, newSwapper);
    }

    /**
     * @notice update the minter contract to a new one
     * @param newMinter the new minter contract
     * @custom:requires owner
     */
    function setMinter(address newMinter) external onlyOwner {
        if (newMinter == address(0)) revert Errors.ZeroAddress();

        address oldMinter = minter;
        minter = newMinter;

        emit MinterUpdated(oldMinter, newMinter);

        WeightedToken[] memory _weightedTokens = weightedTokens;
        uint256 length = _weightedTokens.length;

        for (uint256 i = 0; i < length;) {
            ERC20(_weightedTokens[i].token).safeApprove(newMinter, type(uint256).max);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Set the token to harvest or not
     * @param token the token to harvest or not
     * @param harvestOrNot true or false
     * @custom:requires owner
     */
    function setTokenNotToHarvest(address token, bool harvestOrNot) external onlyOwner {
        if (token == address(0)) revert Errors.ZeroAddress();

        tokensNotToHarvest[token] = harvestOrNot;

        emit TokenNotToHarvestUpdated(token, harvestOrNot);
    }

    /**
     * @notice Recover ERC2O tokens in the contract
     * @dev Recover ERC2O tokens in the contract
     * @param token Address of the ERC2O token
     * @return bool: success
     * @custom:requires owner
     */
    function recoverERC20(address token) external onlyOwner returns (bool) {
        if (token == address(0)) revert Errors.ZeroAddress();

        uint256 amount = ERC20(token).balanceOf(address(this));
        if (amount == 0) revert Errors.ZeroValue();

        ERC20(token).safeTransfer(owner(), amount);

        return true;
    }

    /**
     * @notice Pause the contract
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpause the contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /*//////////////////////////////////////////////////////////////
                            ERC4626 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev totalAssets is the total number of stkWAR
     */
    function totalAssets() public view override returns (uint256) {
        uint256 assets = ERC20(staker).balanceOf(address(this));

        return assets;
    }

    /**
     * @custom:notpaused when not paused
     */
    function deposit(uint256 assets, address receiver) public virtual override whenNotPaused returns (uint256 shares) {
        return super.deposit(assets, receiver);
    }

    /**
     * @custom:notpaused when not paused
     */
    function mint(uint256 shares, address receiver) public virtual override whenNotPaused returns (uint256 assets) {
        return super.mint(shares, receiver);
    }

    /**
     * @custom:notpaused when not paused
     */
    function withdraw(uint256 assets, address receiver, address owner)
        public
        virtual
        override
        whenNotPaused
        returns (uint256 shares)
    {
        return super.withdraw(assets, receiver, owner);
    }

    /**
     * @custom:notpaused when not paused
     */
    function redeem(uint256 shares, address receiver, address owner)
        public
        virtual
        override
        whenNotPaused
        returns (uint256 assets)
    {
        return super.redeem(shares, receiver, owner);
    }

    /**
     * @dev stake assets after each deposit
     */
    function afterDeposit(uint256 assets, uint256 /* shares */ ) internal override {
        IStaker(staker).stake(assets, address(this));
    }

    /**
     * @dev unstake assets before each withdraw to have enough WAR to transfer
     */
    function beforeWithdraw(uint256 assets, uint256 /*shares */ ) internal override {
        IStaker(staker).unstake(assets, address(this));
    }

    /*//////////////////////////////////////////////////////////////
                            HARVEST LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Harvest all rewards from staker
     * @param tokens reward tokens claimed from staker
     * @param callDatas swapper routes to swap to feeToken
     * @custom:requires operator or owner
     */
    function harvest(address[] calldata tokens, bytes[] calldata callDatas) external nonReentrant onlyOperatorOrOwner {
        address _feeToken = feeToken;
        uint256 oldFeeBalance = ERC20(_feeToken).balanceOf(address(this));

        // claim all harvastable rewards
        IStaker.UserClaimableRewards[] memory rewards = IStaker(staker).getUserTotalClaimableRewards(address(this));
        uint256 length = rewards.length;
        for (uint256 i; i < length;) {
            IStaker.UserClaimableRewards memory reward = rewards[i];
            if (reward.claimableAmount != 0 && !tokensNotToHarvest[reward.reward]) {
                IStaker(staker).claimRewards(reward.reward, address(this));
            }
            unchecked {
                ++i;
            }
        }

        // swap to fee token
        length = tokens.length;
        for (uint256 i; i < length;) {
            address token = tokens[i];
            ERC20(token).safeTransfer(swapper, ERC20(token).balanceOf(address(this)));
            unchecked {
                ++i;
            }
        }
        ISwapper(swapper).swap(tokens, callDatas);

        // transfer havestfee %oo to fee recipient
        uint256 harvestedAmount = ERC20(_feeToken).balanceOf(address(this)) - oldFeeBalance;
        ERC20(_feeToken).safeTransfer(feeRecipient, (harvestedAmount * harvestFee) / MAX_BPS);

        emit Harvested(harvestedAmount);
    }

    /**
     * @notice Turn  all rewards into more staked assets
     * @param callDatas swapper routes to swap to more assets
     * @custom:requires operator or owner
     */
    function compound(address[] calldata tokens, bytes[] calldata callDatas)
        external
        nonReentrant
        onlyOperatorOrOwner
    {
        // swap to WeightedTokens with correct ratios
        ERC20(feeToken).safeTransfer(swapper, ERC20(feeToken).balanceOf(address(this)));
        ISwapper(swapper).swap(tokens, callDatas);

        // Mint more stkWAR
        address[] memory weightedTokensAddresses = getWeightedTokenAddresses();
        uint256 length = weightedTokensAddresses.length;
        uint256[] memory amounts = new uint256[](length);
        for (uint256 i; i < length;) {
            amounts[i] = ERC20(weightedTokensAddresses[i]).balanceOf(address(this));
            unchecked {
                ++i;
            }
        }
        IMinter(minter).mintMultiple(weightedTokensAddresses, amounts);
        uint256 stakedAmount = IStaker(staker).stake(ERC20(address(asset)).balanceOf(address(this)), address(this));

        emit Compounded(stakedAmount);
    }

    /**
     * @dev Approve the output tokens to minter
     */
    function setWeightedTokens(WeightedToken[] calldata newWeightedTokens) public override {
        super.setWeightedTokens(newWeightedTokens);

        for (uint256 i; i < newWeightedTokens.length;) {
            Allowance._approveTokenIfNeeded(newWeightedTokens[i].token, minter);
            unchecked {
                ++i;
            }
        }
    }
}
