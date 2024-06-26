import axios from 'axios';
import useSWR from 'swr';
import { zapAddress } from '../config/blockchain';

const fetcher = (data: any) => (url: string) => axios.post(url, data).then((res) => res.data);
export default function useParaswapTransaction(
  user?: `0x${string}`,
  priceRoute?: any,
  slippage?: number,
  timeout?: number
): any | undefined {
  const { data, error, isLoading } = useSWR(
    () => {
      if (!priceRoute || !slippage || !user || !timeout) return undefined;
      return `https://api.paraswap.io/transactions/1?ignoreChecks=true&ignoreGasEstimate=true`;
    },
    fetcher({
      slippage,
      deadline: Date.now() + (timeout || 0),
      srcToken: priceRoute?.srcToken,
      destToken: priceRoute?.destToken,
      srcAmount: priceRoute?.srcAmount,
      priceRoute: priceRoute,
      userAddress: zapAddress,
      srcDecimals: priceRoute?.srcDecimals,
      destDecimals: priceRoute?.destDecimals,
      receiver: zapAddress
    })
  );

  if (isLoading) return undefined;
  if (error) return undefined;
  if (!data) return undefined;
  return data.data;
}
