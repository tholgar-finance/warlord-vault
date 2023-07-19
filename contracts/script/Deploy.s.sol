// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.20;

import {Vault, AWeightedTokens} from "../src/Vault.sol";
import {Zap} from "../src/Zap.sol";
import {Swapper} from "../src/Swapper.sol";
import "forge-std/Script.sol";

contract DeployScript is Script {
    address constant cvxCrv = 0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;
    address constant auraBal = 0x616e8BfA43F920657B3497DBf40D6b1A02D4608d;
    address constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant war = 0xa8258deE2a677874a48F5320670A869D74f0cbC1;
    address constant minter = 0x144a689A8261F1863c89954930ecae46Bd950341;
    address constant staker = 0xA86c53AF3aadF20bE5d7a8136ACfdbC4B074758A;
    address constant aura = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;
    address constant cvx = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address constant augustusSwapper = 0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57;
    address constant tokenTransferAddress = 0x216B4B4Ba9F3e719726886d34a177484278Bfcae;

    uint256 harvestFee;
    address feeRecipient;
    address feeToken;
    address operator;
    AWeightedTokens.WeightedToken[] tokens;
    address newOwner;

    function setUp() public {
        // ALl variables to set up the vault
        harvestFee = 500;
        feeRecipient = makeAddr("feeRecipient");
        operator = makeAddr("operator");
        newOwner = makeAddr("newOwner");

        tokens.push(AWeightedTokens.WeightedToken(address(aura), 6666));
        tokens.push(AWeightedTokens.WeightedToken(address(cvx), 3333));
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.rememberKey(deployerPrivateKey);
        vm.startBroadcast(deployer);

        Swapper swapper = new Swapper(augustusSwapper, tokenTransferAddress);
        console.log("Swapper deployed at: %s", address(swapper));

        // deploy vault
        Vault vault = new Vault(staker, minter, address(swapper), harvestFee, feeRecipient, weth, operator, war);
        console.log("Vault deployed at: %s", address(vault));

        // set output tokens
        uint256 length = tokens.length;
        AWeightedTokens.WeightedToken[] memory outTokens = new AWeightedTokens.WeightedToken[](length);
        for (uint256 i = 0; i < length; i++) {
            outTokens[i] = AWeightedTokens.WeightedToken(tokens[i].token, tokens[i].ratio);
        }
        vault.setWeightedTokens(outTokens);

        // set token to harvest
        vault.setTokenNotToHarvest(cvxCrv, true);
        vault.setTokenNotToHarvest(auraBal, true);

        // deploy zap
        Zap zap = new Zap(war, address(vault), minter);
        console.log("Zap deployed at: %s", address(zap));

        // transfer ownership
        vault.transferOwnership(newOwner);
        swapper.transferOwnership(newOwner);

        vm.stopBroadcast();
    }
}
