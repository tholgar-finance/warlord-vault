import axios from 'axios';
import useSWR from 'swr';

const fetcher = (url: string) => axios.get(url).then((res) => res.data);
export default function useParaswapPrices({
  amount,
  srcToken,
  destToken,
  srcDecimals,
  destDecimals
}: {
  amount: bigint;
  srcToken: string;
  destToken: string;
  srcDecimals?: number;
  destDecimals?: number;
}): { data: any; error: any; isLoading: boolean } {
  return useSWR(() => {
    if (!srcToken || !destToken || !srcDecimals || !destDecimals || amount === 0n) return undefined;
    return `https://api.paraswap.io/prices?version=6.2&srcToken=${srcToken}&destToken=${destToken}&amount=${amount}&side=SELL&network=1&srcDecimals=${srcDecimals}&destDecimals=${destDecimals}`;
  }, fetcher);
}
