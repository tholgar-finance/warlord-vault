/* eslint-disable */

import { FC } from 'react';
import {
  Button,
  Center,
  VStack,
  Text,
  useColorModeValue,
  useDisclosure,
  Box
} from '@chakra-ui/react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { DoubleTokenNumberOutput } from '../../ui/DoubleTokenNumberOutput';
import { faArrowDown } from '@fortawesome/free-solid-svg-icons';
import { DepositPanelModal } from '../DepositModal';
import {
  vaultABI,
  vaultAddress,
  vaultV1Address,
  warIconUrl,
  wstkWarIconUrl
} from 'config/blockchain';
import convertBigintToFormatted from 'utils/convertBigintToFormatted';
import { WalletConnectButton } from 'components/blockchain/WalletConnectButton';
import useConnectedAccount from '../../../hooks/useConnectedAccount';
import { useBalance, useContractRead } from 'wagmi';
import { MigratePanelModal } from '../MigrateModal';

export interface MigratePanelProps {}

export const MigratePanel: FC<MigratePanelProps> = () => {
  const { address, isConnected } = useConnectedAccount();
  const { isOpen, onOpen, onClose } = useDisclosure();

  const tWarBalance = useBalance({
    token: vaultV1Address,
    address,
  })
  console.log(tWarBalance)
  const { data: tWarEquivalent } = useContractRead({
    address: vaultV1Address,
    abi: vaultABI,
    enabled: tWarBalance !== undefined,
    functionName: 'previewRedeem',
    args: [tWarBalance.data?.value ?? 0n],
  });
  const { data: thWarEquivalent } = useContractRead({
    address: vaultAddress,
    abi: vaultABI,
    enabled: tWarEquivalent !== undefined,
    functionName: 'convertToShares',
    args: [tWarEquivalent ?? 0n],
  })
  const isMigrateDisabled = tWarBalance === undefined || tWarEquivalent === undefined || thWarEquivalent === undefined || thWarEquivalent === 0n;
  

  const buttonBgColor = useColorModeValue('brand.primary.200', 'brand.primary.300');
  const buttonHoverColor = useColorModeValue('brand.primary.300', 'brand.primary.100');
  const buttonColor = useColorModeValue('#00cf6f', 'inherit');

  return (
    <>
      <VStack gap={5}>
        <Box w="100%">
          <Text fontSize={'1.125em'} fontWeight={'semibold'}>
            Migrate to v2 vault
          </Text>
          <Text opacity={0.7}>Migrate your tWAR from V1 Vault to V2 Vault.</Text>
        </Box>
        <Box w="100%">
          <VStack gap={2}>
            <Box w="100%">
              <Text fontWeight={'semibold'}>Amount to migrate</Text>
            </Box>

            <Box w="100%">
              <DoubleTokenNumberOutput
                firstTicker={'tWAR'}
                firstIconUrl={wstkWarIconUrl}
                firstValue={tWarBalance.data?.formatted}
                secondTicker={'WAR'}
                secondIconUrl={warIconUrl}
                secondValue={tWarEquivalent !== undefined ? convertBigintToFormatted(tWarEquivalent as bigint, 18) : undefined}
              />
            </Box>
            <Center>
              <FontAwesomeIcon icon={faArrowDown} size={'2x'} opacity={useColorModeValue(0.4, 1)} />
            </Center>
            <Box w="100%">
              <DoubleTokenNumberOutput
                firstTicker={'thWAR'}
                firstIconUrl={wstkWarIconUrl}
                firstValue={thWarEquivalent !== undefined ? convertBigintToFormatted(thWarEquivalent as bigint, 18) : undefined}
                secondTicker={'WAR'}
                secondIconUrl={warIconUrl}
                secondValue={tWarEquivalent !== undefined ? convertBigintToFormatted(tWarEquivalent as bigint, 18) : undefined}
              />
            </Box>
          </VStack>
        </Box>
        <Box w="100%">
            {isConnected ? (
              <Button
                w={'full'}
                backgroundColor={buttonBgColor}
                onClick={onOpen}
                isDisabled={isMigrateDisabled}
                _hover={{ bgColor: buttonHoverColor }}
                color={buttonColor}>
                Migrate
              </Button>
            ) : (
              <WalletConnectButton />
            )}
        </Box>
      </VStack>
      <MigratePanelModal migrationAmount={tWarBalance.data?.value || 0n} open={isOpen} onClose={onClose} />
    </>
  );
};

MigratePanel.defaultProps = {};
