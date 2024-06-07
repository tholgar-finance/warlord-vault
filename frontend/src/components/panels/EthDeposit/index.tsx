import { FC, useCallback, useMemo } from 'react';
import { TokenNumberInput } from '../../inputs/TokenNumberInput';
import { auraCvxIconUrl, ethIconUrl, warAddress, warIconUrl, wethIconUrl } from 'config/blockchain';
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

export interface EthDepositPanelProps {}

export const EthDepositPanel: FC<EthDepositPanelProps> = () => {
  const ethDepositInputAmount = useStore((state) => state.getDepositInputTokenAmount('eth'));
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
      setDepositInputTokenAmount('eth', amountInWei);
    },
    [setDepositInputTokenAmount]
  );

  return (
    <TokenNumberInput
      ticker={'ETH'}
      iconUrl={ethIconUrl}
      value={ethDepositInputAmountFormatted}
      onInputChange={setAmount}
      onInputClear={() => setDepositOutputTokenAmount('thWAR', 0n)}
      onMaxClick={() => {
        setMaxDepositInputTokenAmount('eth');
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

EthDepositPanel.defaultProps = {};
