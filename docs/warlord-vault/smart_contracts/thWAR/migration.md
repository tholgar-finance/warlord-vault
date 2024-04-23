---
sidebar_position: 2
---

# Migration

This is an contract that helps users migrate from v1 vault to v2 one. It simply withdraw from the first vault and redeposit immediatly on the upgraded version.


## State Variables
### oldVault
Address of the old vault


```solidity
address public immutable oldVault;
```


### newVault
Address of the new vault


```solidity
address public immutable newVault;
```


### asset
Address of the asset to be migrated


```solidity
address public immutable asset;
```


## Functions
### constructor


```solidity
constructor(address definitiveOldVault, address definitiveNewVault, address definitiveAsset);
```

### migrate


```solidity
function migrate(uint256 amount, address owner, address receiver) public;
```

