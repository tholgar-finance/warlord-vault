import { FC } from 'react';
import { ContainerProps, HStack, Image, Text, useColorModeValue } from '@chakra-ui/react';
import { Container } from '../Container';

export interface TokenDisplayProps extends ContainerProps {
  /**
   * @property tokenIconUrl The token icon url to display
   */
  tokenIconUrl: string;

  /**
   * @property ticker The token ticker
   */
  ticker: string;
}

export const TokenDisplay: FC<TokenDisplayProps> = ({ tokenIconUrl, ticker, ...props }) => {
  return (
    <Container
      p={2}
      backgroundColor={useColorModeValue('background.100.light', 'background.100.dark')}
      border="0"
      {...props}
    >
      <HStack>
        <Image src={tokenIconUrl} alt={ticker} w={'24px'} />
        <Text fontSize={'l'} fontWeight={'medium'}>
          {ticker}
        </Text>
      </HStack>
    </Container>
  );
};

TokenDisplay.defaultProps = {};
