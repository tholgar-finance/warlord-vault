// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "../MainnetTest.t.sol";
import "src/Vault.sol";
import { Swapper } from "src/Swapper.sol";
import { Errors } from "src/utils/Errors.sol";

contract VaultTest is MainnetTest {
    Vault vault;
    Swapper swapper;

    event MinterUpdated(address oldMinter, address newMinter);
    event StakerUpdated(address oldStaker, address newStaker);
    event TokenNotToHarvestUpdated(address token, bool harvestOrNot);
    event SwapperUpdated(address oldSwapper, address newSwapper);
    event Harvested(uint256 amount);
    event Compounded(uint256 amount);

    function setUp() public virtual override {
        MainnetTest.setUp();
        fork();

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
    }
}
