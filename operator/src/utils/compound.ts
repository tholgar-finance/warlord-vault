import { BigNumber, Contract } from "ethers";
import wallet from "../config/wallet";
import getParaswapData from "./getParaswapData";
import ERC20_ABI from "../abi/ERC20.json";
import STAKER_ABI from "../abi/Staker.json";
import VAULT_ABI from "../abi/Vault.json";
import checkGasPrice from "./checkGasPrice";

const MAX_WEIGHT = 10000;

const compound = async (
  vaultAddress: string,
  stakerAddress: string,
  maxGasPrice: number,
  slippage: number,
  ratios: Map<string, BigNumber>,
  execute: boolean = true
) => {
  const provider = wallet.provider;

  const gasPrice = await checkGasPrice(maxGasPrice);

  // Create vault contract
  const vault = new Contract(vaultAddress, VAULT_ABI, provider);
  const staker = new Contract(stakerAddress, STAKER_ABI, provider);

  // Get swap data for fee token to mintable token
  const outputData: string[] = [];
  const tokensToMint: string[] = [];
  const tokensToSwap: string[] = [];
  try {
    const chainId = (await provider.getNetwork()).chainId;
    const feeToken = await vault.feeToken();
    const feeContract = new Contract(feeToken, ERC20_ABI, provider);
    const srcDecimals = await feeContract.decimals();
    const swapperAddress = await vault.swapper();

    const rewards = await staker.getUserTotalClaimableRewards(vaultAddress);
    const swapperBalance = await feeContract.balanceOf(swapperAddress);
    const balance = rewards.find((r: any) => r[0] === feeToken)?.[1].add(swapperBalance).mul((await vault.MAX_BPS()).sub(await vault.harvestFee())).div(await vault.MAX_BPS());

    for (let i = 0; i < ratios.size; i++) {
      tokensToSwap.push(feeToken);
    }
    for (const [key, _] of ratios) {
      tokensToMint.push(key);
    }

    for (const token of tokensToMint) {
      const tokenContract = new Contract(token, ERC20_ABI, provider);
      const destDecimals = await tokenContract.decimals();
      const amount = balance.mul(ratios.get(token)!).div(MAX_WEIGHT);
      const data = await getParaswapData(
        feeToken,
        srcDecimals,
        token,
        destDecimals,
        amount,
        swapperAddress,
        chainId,
        slippage,
        vaultAddress
      );
      outputData.push(data);
    }
  } catch (err: any) {
    throw new Error(`Cannot get output data: ${err.message}`);
  }

  if (!execute) {
    const calldata = vault.interface.encodeFunctionData("compound", [
      tokensToSwap,
      outputData,
      tokensToMint,
    ]);
    console.log(tokensToSwap,
      outputData,
      tokensToMint);
  } else {
    try {
      // Compound the rewards
      const tx = await vault.compound(tokensToSwap, outputData, tokensToMint, {
        gasPrice: BigNumber.from(gasPrice).mul(10000000000),
      });

      const receipt = await tx.wait();
      if (receipt.status === 0) {
        throw new Error(`Transaction reverted: ${tx.hash}`);
      }
    } catch (err: any) {
      throw new Error(`Cannot compound: ${err.message}`);
    }
  }
};

export default compound;
