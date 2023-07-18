import { FC, useEffect } from 'react';
import { Flex } from '@chakra-ui/react';
import { TokenNumberOutput } from '../../ui/TokenNumberOutput';

export interface AuraCvxWithdrawPanelProps {
  amounts: { token: string; amount: string }[];
  // eslint-disable-next-line no-unused-vars
  setAmount: (amounts: { token: string; amount: string }[]) => void;
}

export const AuraCvxWithdrawPanel: FC<AuraCvxWithdrawPanelProps> = ({ amounts, setAmount }) => {
  const auraAmount = amounts.find((am) => am.token == 'aura')?.amount || '0';
  const cvxAmount = amounts.find((am) => am.token == 'cvx')?.amount || '0';

  useEffect(() => {
    if (!amounts.find((am) => am.token == 'aura')) {
      setAmount([...amounts, { token: 'aura', amount: '0' }]);
    }
    if (!amounts.find((am) => am.token == 'cvx')) {
      setAmount([...amounts, { token: 'cvx', amount: '0' }]);
    }
  }, [amounts, setAmount]);

  return (
    <Flex direction={'column'} gap={4}>
      <TokenNumberOutput
        ticker={'AURA'}
        iconUrl={'https://www.convexfinance.com/static/icons/svg/vlcvx.svg'}
        value={auraAmount}
      />
      <TokenNumberOutput
        ticker={'CVX'}
        iconUrl={'https://www.convexfinance.com/static/icons/svg/vlcvx.svg'}
        value={cvxAmount}
      />
    </Flex>
  );
};

AuraCvxWithdrawPanel.defaultProps = {};