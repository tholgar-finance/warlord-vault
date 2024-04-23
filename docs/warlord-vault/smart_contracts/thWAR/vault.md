---
sidebar_position: 1
---

# Vault

This is the main contract of the Warlord protocol. It allows user to deposit WAR that will then be staked in the Warlord staking contract. It also handles the harvest and compound logic of the vault. Some admins functions are here to handle fees and pause the contract if needed. The Vault itself can change staker but not the underlying asset.


## State Variables
### _asset
Address of the definitive asset()


```solidity
address private immutable _asset;
```


### _NAME
Name of the vault


```solidity
string private constant _NAME = "Tholgar Warlord Vault";
```


### _SYMBOL
Symbol of the vault


```solidity
string private constant _SYMBOL = "thWAR";
```


### staker
Address of the stkWAR token


```solidity
address public staker;
```


### minter
Address of the WAR minter contract


```solidity
address public minter;
```


### swapper
Address of the swapper contract


```solidity
address public swapper;
```


## Functions
### constructor


```solidity
constructor(
    address initialOwner,
    address initialStaker,
    address initialMinter,
    address initialSwapper,
    uint256 initialHarvestFee,
    uint256 initialWithdrawalFee,
    address initialFeeRecipient,
    address initialFeeToken,
    address initialOperator,
    address definitiveAsset
)
    Owned2Step(initialOwner)
    AFees(initialHarvestFee, initialWithdrawalFee, initialFeeRecipient, initialFeeToken)
    AOperator(initialOperator);
```

### setStaker

update the staker contract to a new one


```solidity
function setStaker(address newStaker) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newStaker`|`address`|the new staker contract|


### setSwapper

update the swapper contract to a new one


```solidity
function setSwapper(address newSwapper) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newSwapper`|`address`|the new swapper contract|


### setMinter

update the minter contract to a new one


```solidity
function setMinter(address newMinter) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMinter`|`address`|the new minter contract|


### recoverERC20

Recover ERC2O tokens in the contract

*Recover ERC2O tokens in the contract*


```solidity
function recoverERC20(address token) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Address of the ERC2O token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool: success|


### pause

Pause the contract


```solidity
function pause() external onlyOwner;
```

### unpause

Unpause the contract


```solidity
function unpause() external onlyOwner;
```

### name

*Returns the name of the token*


```solidity
function name() public view override returns (string memory);
```

### symbol

*Returns the symbol of the token*


```solidity
function symbol() public view override returns (string memory);
```

### previewRedeem

*previewRedeem returns the amount of assets that will be redeemed minus the withdrawal fees*


```solidity
function previewRedeem(uint256 shares) public view override returns (uint256 assets);
```

### asset

*asset is the definitive asset of the vault (WAR)*


```solidity
function asset() public view override returns (address);
```

### totalAssets

*totalAssets is the total number of stkWAR*


```solidity
function totalAssets() public view override returns (uint256);
```

### deposit


```solidity
function deposit(uint256 assets, address receiver) public override whenNotPaused returns (uint256 shares);
```

### mint


```solidity
function mint(uint256 shares, address receiver) public override whenNotPaused returns (uint256 assets);
```

### withdraw


```solidity
function withdraw(uint256 assets, address to, address owner) public override whenNotPaused returns (uint256 shares);
```

### redeem


```solidity
function redeem(uint256 shares, address to, address owner) public override whenNotPaused returns (uint256 assets);
```

### _afterDeposit

*stake assets after each deposit*


```solidity
function _afterDeposit(uint256 assets, uint256) internal override;
```

### _beforeWithdraw

*unstake assets before each withdraw to have enough WAR to transfer*


```solidity
function _beforeWithdraw(uint256 assets, uint256) internal override;
```

### harvest

Harvest all rewards from staker

*calldatas should swap from all reward tokens to feeToken*


```solidity
function harvest(address[] calldata tokensToHarvest, address[] calldata tokensToSwap, bytes[] calldata callDatas)
    external
    nonReentrant
    onlyOperatorOrOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokensToHarvest`|`address[]`|tokens to harvest|
|`tokensToSwap`|`address[]`|tokens to swap to feeToken|
|`callDatas`|`bytes[]`|swapper routes to swap to feeToken|


### compound

Turn all rewards into more staked assets


```solidity
function compound(address[] calldata tokensToSwap, bytes[] calldata callDatas, address[] calldata tokensToMint)
    external
    nonReentrant
    onlyOperatorOrOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokensToSwap`|`address[]`|tokens which includes the feeToken to swap to more assets|
|`callDatas`|`bytes[]`|swapper routes to swap to more assets|
|`tokensToMint`|`address[]`|tokens to mint more stkWAR|


## Events
### StakerUpdated
Event emitted when a staker is updated


```solidity
event StakerUpdated(address oldStaker, address newStaker);
```

### MinterUpdated
Event emitted when a minter is updated


```solidity
event MinterUpdated(address oldMinter, address newMinter);
```

### SwapperUpdated
Event emitted when a swapper is updated


```solidity
event SwapperUpdated(address oldSwapper, address newSwapper);
```

### Harvested
Event emitted when reward have been harvested


```solidity
event Harvested(uint256 amount);
```

### Compounded
Event emitted when rewards are compounded into more stkWAR


```solidity
event Compounded(uint256 amount);
```