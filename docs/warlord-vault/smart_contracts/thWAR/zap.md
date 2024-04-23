---
sidebar_position: 3
---

# Zap

This is an util contract to ease the deposit of aura/cvx or any ERC20 into the vault. It will first mint WAR with the amount of aura/cvx you want to deposit, then deposit it into the vault for tWAR.


## State Variables
### AURA
Address of the AURA token


```solidity
address public constant AURA = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;
```


### CVX
Address of the Convex token


```solidity
address public constant CVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
```


### WETH
Address of the WETH token


```solidity
address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
```


### WAR
Address of the War token


```solidity
address public constant WAR = 0xa8258deE2a677874a48F5320670A869D74f0cbC1;
```


### swapRouter
Dex/aggregaor router to call to perform swaps


```solidity
address public swapRouter;
```


### tokenTransferAddress
Address to allow to swap tokens


```solidity
address public tokenTransferAddress;
```


### warMinter
Address of the WarMinter contract


```solidity
address public warMinter;
```


### vault
Address of the ERC4626 vault


```solidity
address public vault;
```


## Functions
### constructor


```solidity
constructor(
    address initialOwner,
    address initialSwapRouter,
    address initialTokenTransferAddress,
    address initialWarMinter,
    address initialVault
) Owned2Step(initialOwner);
```

### resetWarlordAllowances

*Resets the allowances for Warlord-related interactions.*


```solidity
function resetWarlordAllowances() external onlyOwner;
```

### removeWarlordAllowances

*Removes the allowances for Warlord-related interactions.*


```solidity
function removeWarlordAllowances() external onlyOwner;
```

### removeRouterAllowance


```solidity
function removeRouterAllowance(address token) external onlyOwner;
```

### setWarMinter

Set the WarMinter address


```solidity
function setWarMinter(address newWarMinter) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newWarMinter`|`address`|address of the WarMinter|


### setSwapRouter

Set the dex/aggregator router to call to perform swaps


```solidity
function setSwapRouter(address newSwapRouter) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newSwapRouter`|`address`|address of the router|


### setTokenTransferAddress

Set the token proxy address to allow to swap tokens


```solidity
function setTokenTransferAddress(address newTokenTransferAddress) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newTokenTransferAddress`|`address`|address of the token proxy|


### setVault

Set the vault address


```solidity
function setVault(address newVault) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newVault`|`address`|address of the vault|


### _swap

Perform the swap using the router/aggregator


```solidity
function _swap(address[] memory tokens, bytes[] memory callDatas) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokens`|`address[]`|array of tokens to swap|
|`callDatas`|`bytes[]`|bytes to call the router/aggregator|


### _performRouterSwap

Perform the swap using the router/aggregator


```solidity
function _performRouterSwap(bytes memory callData) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`callData`|`bytes`|bytes to call the router/aggregator|


### _mintSingleToken

Mint a single vlToken


```solidity
function _mintSingleToken(address receiver, address vlToken, uint256 amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`address`|Address to stake for|
|`vlToken`|`address`|Token to mint WAR|
|`amount`|`uint256`|Amount of token to mint|


### _swapAndMintSingleToken

Swap to a single vlToken and mint tWAR


```solidity
function _swapAndMintSingleToken(address receiver, address token, address vlToken, bytes memory callDatas) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`address`|Address to stake for|
|`token`|`address`|Token to swap|
|`vlToken`|`address`|Token to mint WAR|
|`callDatas`|`bytes`|bytes to call the router/aggregator|


### _mintMultipleTokens

Mint multiple vlTokens


```solidity
function _mintMultipleTokens(address receiver, address[] memory vlTokens, uint256[] memory amounts) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`address`|Address to stake for|
|`vlTokens`|`address[]`|Tokens to mint WAR|
|`amounts`|`uint256[]`|Amounts to mint|


### _swapAndMintMultipleTokens

Swap to multiple vlTokens and mint tWAR


```solidity
function _swapAndMintMultipleTokens(
    address receiver,
    address token,
    address[] memory vlTokens,
    bytes[] memory callDatas
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`address`|Address to stake for|
|`token`|`address`|Token to swap|
|`vlTokens`|`address[]`|Tokens to mint WAR|
|`callDatas`|`bytes[]`|bytes to call the router/aggregator|


### zapEtherToSingleToken

Zaps ether to a single vlToken


```solidity
function zapEtherToSingleToken(address vlToken, address receiver, bytes calldata callDatas) external payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`vlToken`|`address`|Token to mint WAR|
|`receiver`|`address`|Address to stake for|
|`callDatas`|`bytes`|bytes to call the router/aggregator|


### zapERC20ToSingleToken

Zaps an ERC20 token to a single vlToken


```solidity
function zapERC20ToSingleToken(
    address token,
    address vlToken,
    uint256 amount,
    address receiver,
    bytes calldata callDatas
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Token to swap|
|`vlToken`|`address`|Token to mint WAR|
|`amount`|`uint256`|Amount of token to swap|
|`receiver`|`address`|Address to stake for|
|`callDatas`|`bytes`|bytes to call the router/aggregator|


### zapEtherToMultipleTokens

Zaps ether to multiple vlTokens


```solidity
function zapEtherToMultipleTokens(address[] calldata vlTokens, address receiver, bytes[] calldata callDatas)
    external
    payable;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`vlTokens`|`address[]`|List of token addresses to deposit|
|`receiver`|`address`|Address to stake for|
|`callDatas`|`bytes[]`|bytes to call the router/aggregator|


### zapERC20ToMultipleTokens

Zaps an ERC20 token to multiple vlTokens


```solidity
function zapERC20ToMultipleTokens(
    address token,
    address[] calldata vlTokens,
    uint256 amount,
    address receiver,
    bytes[] calldata callDatas
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Token to swap|
|`vlTokens`|`address[]`|List of token addresses to deposit|
|`amount`|`uint256`|Amount of token to swap|
|`receiver`|`address`|Address to stake for|
|`callDatas`|`bytes[]`|bytes to call the router/aggregator|


### zapVlToken

Zaps a vlToken to tWAR


```solidity
function zapVlToken(address vlToken, uint256 amount, address receiver) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`vlToken`|`address`|Token to mint WAR|
|`amount`|`uint256`|Amount of token to swap|
|`receiver`|`address`|Address to stake for|


### zapVlTokens

Zaps multiple vlTokens to tWAR


```solidity
function zapVlTokens(address[] calldata vlTokens, uint256[] calldata amounts, address receiver) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`vlTokens`|`address[]`|List of token addresses to deposit|
|`amounts`|`uint256[]`|List of token amounts to deposit|
|`receiver`|`address`|Address to stake for|


## Events
### Zapped
This event is emitted when a zap operation occurs.


```solidity
event Zapped(uint256 mintedAmount, address receiver);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`mintedAmount`|`uint256`|The amount of WAR tokens minted as a result.|
|`receiver`|`address`|The address of the recipient of the WAR tokens.|

### SetWarMinter
This event is emitted when the WarMinter address is changed.


```solidity
event SetWarMinter(address newMinter);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMinter`|`address`|The new WarMinter address.|

### SetWarStaker
This event is emitted when the WarStaker address is changed.


```solidity
event SetWarStaker(address newStaker);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newStaker`|`address`|The new WarStaker address.|

### SwapRouterUpdated
Event emitted when the swap router is updated


```solidity
event SwapRouterUpdated(address newSwapRouter);
```

### TokenTransferAddressUpdated
Event emitted when the token proxy is updated


```solidity
event TokenTransferAddressUpdated(address newTokenTransferAddress);
```

### VaultUpdated
Event emitted when the vault is updated


```solidity
event VaultUpdated(address newVault);
```