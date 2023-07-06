import { FC } from 'react';
import { Container } from 'components/ui/Container';
import {BalanceDisplay} from "../../components/blockchain/BalanceDisplay";

const AutoCompounder: FC = () => {
  return <Container p={4}>
    <BalanceDisplay token={'0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'} description={"USDC Balance"} />
  </Container>
};

export default AutoCompounder;