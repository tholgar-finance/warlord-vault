import { FC } from 'react';
import { Button, Flex, Text, useColorModeValue } from '@chakra-ui/react';
import { Container } from 'components/ui/Container';
import { Link } from 'react-router-dom';

export interface AjnaBannerProps {}

export const AjnaBanner: FC<AjnaBannerProps> = () => {
  return (
    <Container mx={'4em'} borderRadius={'1.5em'}>
      <Flex justify="space-between" align="center">
        <Text fontSize={'1.1em'} fontWeight={'bold'}>
          Ajna pool is live on Arbitrum ! Use it to borrow USDC against your tWAR.
        </Text>
        <Link target='_blank' to={'https://ajnafi.com/arbitrum/pools/0xe20440d3c74257a37b93720177343e6739d56beb'}>
          <Button backgroundColor={useColorModeValue('brand.primary.200', 'brand.primary.300')}>
            Borrow
          </Button>
        </Link>
      </Flex>
    </Container>
  );
};

AjnaBanner.defaultProps = {};
