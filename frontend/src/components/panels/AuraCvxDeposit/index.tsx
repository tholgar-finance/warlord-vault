import { FC, useCallback, useMemo } from 'react';
import { Flex } from '@chakra-ui/react';
import { auraAddress, auraIconUrl, cvxAddress, cvxIconUrl } from '../../../config/blockchain';
import { TokenNumberInput } from '../../inputs/TokenNumberInput';
import useOrFetchTokenInfos from '../../../hooks/useOrFetchTokenInfos';
import { useStore } from '../../../store';
import convertBigintToFormatted from '../../../utils/convertBigintToFormatted';
import convertFormattedToBigInt from '../../../utils/convertFormattedToBigInt';
import { TokenDisplay } from 'components/ui/TokenDisplay';

export interface AuraCvxDepositPanelProps {}

export const AuraCvxDepositPanel: FC<AuraCvxDepositPanelProps> = () => {
  const auraInfos = useOrFetchTokenInfos({ token: 'aura' });
  const auraDecimals = auraInfos?.decimals;
  const cvxInfos = useOrFetchTokenInfos({ token: 'cvx' });
  const cvxDecimals = cvxInfos?.decimals;
  const auraDepositInputAmount = useStore((state) => state.getDepositInputTokenAmount('aura'));
  const cvxDepositInputAmount = useStore((state) => state.getDepositInputTokenAmount('cvx'));
  const [setDepositInputTokenAmount, setMaxDepositInputTokenAmount] = useStore((state) => [
    state.setDepositInputTokenAmount,
    state.setMaxDepositInputTokenAmount
  ]);
  const setDepositOutputTokenAmount = useStore((state) => state.setDepositOutputTokenAmount);
  const auraDepositInputAmountFormatted = useMemo(() => {
    if (!auraDecimals) return '0';
    return convertBigintToFormatted(auraDepositInputAmount, auraDecimals);
  }, [auraDepositInputAmount, auraDecimals]);
  const cvxDepositInputAmountFormatted = useMemo(() => {
    if (!cvxDecimals) return '0';
    return convertBigintToFormatted(cvxDepositInputAmount, cvxDecimals);
  }, [cvxDepositInputAmount, cvxDecimals]);
  const setAuraAmount = useCallback(
    (amount: string) => {
      if (!auraDecimals) return;
      const amountInWei = convertFormattedToBigInt(amount, auraDecimals);
      setDepositInputTokenAmount('aura', amountInWei);
    },
    [auraDecimals, setDepositInputTokenAmount]
  );
  const setCvxAmount = useCallback(
    (amount: string) => {
      if (!cvxDecimals) return;
      const amountInWei = convertFormattedToBigInt(amount, cvxDecimals);
      setDepositInputTokenAmount('cvx', amountInWei);
    },
    [cvxDecimals, setDepositInputTokenAmount]
  );

  return (
    <Flex direction={'column'} gap={2}>
      <TokenNumberInput
        token={auraAddress}
        ticker={'AURA'}
        iconUrl={auraIconUrl}
        value={auraDepositInputAmountFormatted}
        onInputChange={setAuraAmount}
        onInputClear={() => setDepositOutputTokenAmount('thWAR', 0n)}
        onMaxClick={() => setMaxDepositInputTokenAmount('aura')}
        rightElement={
          <TokenDisplay tokenIconUrl={auraIconUrl} ticker={'AURA'} />
        }
      />
      <TokenNumberInput
        token={cvxAddress}
        ticker={'CVX'}
        iconUrl={cvxIconUrl}
        value={cvxDepositInputAmountFormatted}
        onInputChange={setCvxAmount}
        onInputClear={() => setDepositOutputTokenAmount('thWAR', 0n)}
        onMaxClick={() => setMaxDepositInputTokenAmount('cvx')}
        rightElement={
          <TokenDisplay tokenIconUrl={cvxIconUrl} ticker={'CVX'} />
        }
      />
    </Flex>
  );
};

AuraCvxDepositPanel.defaultProps = {};
