// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import { Migration } from "src/Migration.sol";
import { Errors } from "src/utils/Errors.sol";
import { Swapper } from "src/Swapper.sol";
import "src/Vault.sol";
import { MainnetTest } from "../MainnetTest.t.sol";

contract MigrationTest is MainnetTest {
    Migration migration;
    ERC4626 oldVault;
    Vault vault;
    Swapper swapper;

    function setUp() public virtual override {
        MainnetTest.setUp();
        fork(19_698_776);

        vm.startPrank(owner);

        swapper = new Swapper(owner, augustusSwapper, tokenTransferAddress);

        vault = new Vault(
            owner,
            address(staker),
            address(minter),
            address(swapper),
            500,
            150,
            owner,
            address(usdc),
            operator,
            address(war)
        );

        swapper.setVault(address(vault));
        vm.stopPrank();


        oldVault = ERC4626(0x188cA46Aa2c7ae10C14A931512B62991D5901453);

        vm.prank(owner);
        migration = new Migration(address(oldVault), address(vault), address(war));
    }
}
