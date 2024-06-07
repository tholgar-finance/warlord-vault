import { FC, useCallback, useMemo } from 'react';
import { TokenNumberInput } from '../../inputs/TokenNumberInput';
import { ethIconUrl, warIconUrl, wethAddress, wethIconUrl } from 'config/blockchain';
import { tokensSelection, useStore } from '../../../store';
import convertBigintToFormatted from '../../../utils/convertBigintToFormatted';
import convertFormattedToBigInt from '../../../utils/convertFormattedToBigInt';
import { TokenSelector } from 'components/ui/TokenSelector';

const tokensDetails = [
  { id: 'war', name: 'WAR', iconUrl: warIconUrl },
  {
    id: 'eth',
    name: 'ETH',
    iconUrl: ethIconUrl
  },
  {
    id: 'weth',
    name: 'WETH',
    iconUrl: wethIconUrl
  }
];

export interface WethDepositPanelProps {}

export const WethDepositPanel: FC<WethDepositPanelProps> = () => {
  const ethDepositInputAmount = useStore((state) => state.getDepositInputTokenAmount('weth'));
  const [singleDepositToken, setDepositToken, setSingleDepositInputToken] = useStore((state) => [
    state.singleDepositToken,
    state.setDepositToken,
    state.setSingleDepositToken
  ]);
  const [setDepositInputTokenAmount, setMaxDepositInputTokenAmount] = useStore((state) => [
    state.setDepositInputTokenAmount,
    state.setMaxDepositInputTokenAmount
  ]);
  const setDepositOutputTokenAmount = useStore((state) => state.setDepositOutputTokenAmount);
  const ethDepositInputAmountFormatted = useMemo(() => {
    return convertBigintToFormatted(ethDepositInputAmount, 18);
  }, [ethDepositInputAmount]);
  const setAmount = useCallback(
    (amount: string) => {
      const amountInWei = convertFormattedToBigInt(amount, 18);
      setDepositInputTokenAmount('weth', amountInWei);
    },
    [setDepositInputTokenAmount]
  );

  return (
    <TokenNumberInput
      token={wethAddress}
      ticker={'WETH'}
      iconUrl={wethIconUrl}
      value={ethDepositInputAmountFormatted}
      onInputChange={setAmount}
      onInputClear={() => setDepositOutputTokenAmount('thWAR', 0n)}
      onMaxClick={() => {
        setMaxDepositInputTokenAmount('weth');
      }}
      rightElement={
        <TokenSelector 
          tokens={tokensDetails} 
          selection={singleDepositToken} 
          onTokenSelect={(token) => {
            setDepositToken(token as tokensSelection)
            setSingleDepositInputToken(token as tokensSelection)
          }}
        />
      }
    />
  );
};

WethDepositPanel.defaultProps = {};
