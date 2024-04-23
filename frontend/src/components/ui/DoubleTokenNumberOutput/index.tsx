import { FC } from 'react';
import { Container } from 'components/ui/Container';
import { Flex, VStack, Text, useColorModeValue, Divider } from '@chakra-ui/react';
import { TokenDisplay } from '../TokenDisplay';

export interface DoubleTokenNumberOutputProps {
  firstTicker: string;
  firstIconUrl: string;
  firstValue?: string;
  secondTicker: string;
  secondIconUrl: string;
  secondValue?: string;
}

export const DoubleTokenNumberOutput: FC<DoubleTokenNumberOutputProps> = ({ firstTicker, firstIconUrl, firstValue, secondTicker, secondIconUrl, secondValue }) => (
  <Container
    px={4}
    py={2}
    m={0}
    backgroundColor={useColorModeValue('background.200.light', 'background.200.dark')}>
    <Flex justify={'space-between'} my={1}>
      <VStack align={'start'} justify={'center'}>
        <Text fontSize={'1.5em'}>{firstValue ?? '0'}</Text>
      </VStack>
      <VStack justify={'center'}>
        <TokenDisplay my={1} tokenIconUrl={firstIconUrl} ticker={firstTicker} />
      </VStack>
    </Flex>
    <Divider borderWidth='1px' borderColor={"whiteAlpha.300"} my={2} />
    <Flex justify={'space-between'}>
      <VStack align={'start'} justify={'center'}>
        <Text fontSize={'1.5em'}>{secondValue ?? '0'}</Text>
      </VStack>
      <VStack justify={'center'}>
        <TokenDisplay my={1} tokenIconUrl={secondIconUrl} ticker={secondTicker} />
      </VStack>
    </Flex>
  </Container>
);

DoubleTokenNumberOutput.defaultProps = {};
