// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "../MainnetTest.t.sol";
import { Swapper } from "src/Swapper.sol";
import { ERC20Mock } from "../mock/ERC20.sol";
import { Errors } from "src/utils/Errors.sol";

contract SwapperTest is MainnetTest {
    Swapper swapper;
    address vault = makeAddr("vault");

    event VaultUpdated(address oldVault, address newVault);
    event SwapRouterUpdated(address oldSwapRouter, address newSwapRouter);
    event TokenTransferAddressUpdated(address oldTokenTransferAddress, address newTokenTransferAddress);

    function setUp() public virtual override {
        super.setUp();
        fork();

        vm.startPrank(owner);

        swapper = new Swapper(owner, augustusSwapper, tokenTransferAddress);

        swapper.setVault(vault);

        vm.stopPrank();
    }
}
