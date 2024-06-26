import { FC, useEffect, useMemo } from 'react';
import { Flex } from '@chakra-ui/react';
import { TokenNumberOutput } from '../../ui/TokenNumberOutput';
import { stakerAddress, vaultAddress, vaultV1Address, warIconUrl } from 'config/blockchain';
import { useStore } from '../../../store';
import useOrFetchTokenInfos from '../../../hooks/useOrFetchTokenInfos';
import convertBigintToFormatted from '../../../utils/convertBigintToFormatted';
import { useBalance } from 'wagmi';

export interface WarWithdrawPanelProps {
  token: 'thWAR' | 'tWAR';
}

export const WarWithdrawPanel: FC<WarWithdrawPanelProps> = ({ token }) => {
  const war = useOrFetchTokenInfos({ token: 'war' });
  const vault = useOrFetchTokenInfos({ token });
  const { data: stakerBalance } = useBalance({
    token: stakerAddress,
    address: token == 'thWAR' ? vaultAddress : vaultV1Address
  });
  const wstkWARWithdrawInputAmount = useStore((state) => state.getWithdrawInputTokenAmount(token));
  const warWithdrawOutputAmount = useStore((state) => state.getWithdrawOutputTokenAmount('war'));
  const setWithdrawOutputAmount = useStore((state) => state.setWithdrawOutputTokenAmount);
  const warWithdrawOutputAmountFormatted = useMemo(() => {
    if (!war || !war?.decimals) return '0';
    return convertBigintToFormatted(warWithdrawOutputAmount, war.decimals);
  }, [warWithdrawOutputAmount, war]);

  useEffect(() => {
    if (!vault || stakerBalance === undefined || vault?.totalSupply === undefined) return;
    setWithdrawOutputAmount(
      'war',
      vault.totalSupply === 0n
        ? wstkWARWithdrawInputAmount * 98500n / 100000n
        : wstkWARWithdrawInputAmount * stakerBalance.value / vault.totalSupply * 98500n / 100000n
    );
  }, [wstkWARWithdrawInputAmount, vault, stakerBalance]);

  return (
    <Flex direction={'column'}>
      <TokenNumberOutput
        ticker={'WAR'}
        iconUrl={warIconUrl}
        value={warWithdrawOutputAmountFormatted}
      />
    </Flex>
  );
};

WarWithdrawPanel.defaultProps = {};
