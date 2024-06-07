import { FC, useCallback, useMemo } from 'react';
import { TokenNumberInput } from '../../inputs/TokenNumberInput';
import { auraCvxIconUrl, ethIconUrl, warAddress, warIconUrl, wethIconUrl } from 'config/blockchain';
import { tokensSelection, useStore } from '../../../store';
import useOrFetchTokenInfos from '../../../hooks/useOrFetchTokenInfos';
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

export interface WarDepositPanelProps {}

export const WarDepositPanel: FC<WarDepositPanelProps> = () => {
  const warInfos = useOrFetchTokenInfos({ token: 'war' });
  const warDecimals = warInfos?.decimals;
  const warDepositInputAmount = useStore((state) => state.getDepositInputTokenAmount('war'));
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
  const warDepositInputAmountFormatted = useMemo(() => {
    if (!warDecimals) return '0';
    return convertBigintToFormatted(warDepositInputAmount, warDecimals);
  }, [warDepositInputAmount, warDecimals]);
  const setAmount = useCallback(
    (amount: string) => {
      if (!warDecimals) return;
      const amountInWei = convertFormattedToBigInt(amount, warDecimals);
      setDepositInputTokenAmount('war', amountInWei);
    },
    [warDecimals, setDepositInputTokenAmount]
  );

  return (
    <TokenNumberInput
      token={warAddress}
      ticker={'WAR'}
      iconUrl={warIconUrl}
      value={warDepositInputAmountFormatted}
      onInputChange={setAmount}
      onInputClear={() => setDepositOutputTokenAmount('thWAR', 0n)}
      onMaxClick={() => {
        setMaxDepositInputTokenAmount('war');
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

WarDepositPanel.defaultProps = {};
