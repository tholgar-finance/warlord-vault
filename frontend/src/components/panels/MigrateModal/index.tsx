import { FC, useCallback, useEffect, useMemo } from 'react';
import {
  Button,
  Center,
  Flex,
  HStack,
  Modal,
  ModalBody,
  ModalCloseButton,
  ModalContent,
  ModalHeader,
  ModalOverlay,
  Spinner,
  Switch,
  useBoolean,
  useColorModeValue,
  useSteps,
  Text,
} from '@chakra-ui/react';
import { ProgressStepper } from '../../ui/ProgressStepper';
import { useStore } from '../../../store';
import { erc20ABI, useContractRead, useContractWrite, useWaitForTransaction } from 'wagmi';
import { maxAllowance, migratorAddress, vaultABI, vaultAddress, vaultV1Address } from '../../../config/blockchain';
import useConnectedAccount from '../../../hooks/useConnectedAccount';
import { migratorAbi } from 'config/abi/Migrator';

export interface ApproveAllowanceProps {
  tokenAddress: `0x${string}`;
  allowanceFor: `0x${string}`;
  amount: bigint;
  step: number;
  validateStep: () => void;
  address: `0x${string}`;
}

export const ApproveAllowance: FC<ApproveAllowanceProps> = ({
  validateStep,
  address,
  tokenAddress,
  amount,
  allowanceFor
}) => {
  const [allowTotal, setAllowTotal] = useBoolean(false);
  const [validated, setValidated] = useBoolean(false);
  const { data, write } = useContractWrite({
    address: tokenAddress,
    abi: erc20ABI,
    functionName: 'approve'
  });
  const { isLoading, isSuccess } = useWaitForTransaction({
    hash: data?.hash
  });
  const allowanceRes = useContractRead({
    address: tokenAddress,
    abi: erc20ABI,
    functionName: 'allowance',
    args: [address, allowanceFor]
  });
  const allow = useCallback(() => {
    if (!isLoading && !isSuccess) {
      write({
        args: [allowanceFor, allowTotal ? maxAllowance : amount]
      });
    }
  }, [amount, allowTotal, write, isLoading, isSuccess, allowanceFor]);

  useEffect(() => {
    if (isSuccess && !validated) {
      setValidated.on();
      validateStep();
    }
  }, [isSuccess, validateStep]);

  useEffect(() => {
    if (allowanceRes.data && allowanceRes.data >= amount) validateStep();
  }, [allowanceRes, amount, validateStep]);

  return (
    <Flex direction={'column'}>
      <HStack>
        <Text>Allowance type : </Text>
        <Center>
          <HStack>
            <Text>Deposit amount</Text>
            <Switch onChange={setAllowTotal.toggle} colorScheme="green" />
            <Text>Max allowance</Text>
          </HStack>
        </Center>
      </HStack>
      <Button
        my={5}
        onClick={allow}
        disabled={isLoading}
        backgroundColor={useColorModeValue('brand.primary.200', 'brand.primary.300')}
        _hover={{ bgColor: useColorModeValue('brand.primary.300', 'brand.primary.100') }}
        color={useColorModeValue('#00cf6f', 'inherit')}>
        {isLoading ? <Spinner /> : 'Approve'}
      </Button>
    </Flex>
  );
};

export interface MigratePanelModalProps {
  migrationAmount: bigint;
  open: boolean;
  onClose: () => void;
}

export const MigratePanelModal: FC<MigratePanelModalProps> = ({ migrationAmount, open, onClose }) => {
  const resetBalances = useStore((state) => state.resetBalances);
  const resetStats = useStore((state) => state.resetStats);
  const { address } = useConnectedAccount();
  const { data: migrateData, write: writeMigrate } = useContractWrite({
    address: migratorAddress,
    abi: migratorAbi,
    functionName: 'migrate'
  });

  const { isLoading, isSuccess } = useWaitForTransaction({
    hash: migrateData?.hash
  });
  const migrate = useCallback(() => {
    if (!isLoading && !isSuccess) {
      writeMigrate({
        args: [migrationAmount, address, address]
      });
    }
  }, [migrationAmount, address]);
  const steps = useMemo(() => ([
      {
        label: 'Approve tWAR',
        description: 'Approve previous token for migration'
      },
      {
        label: 'Migrate',
        description: 'Migrate to new token'
      }
    ]
  ), []);
  const { activeStep, goToNext } = useSteps({
    index: 0,
    count: steps.length
  });

  useEffect(() => {
    if (isSuccess) {
      resetBalances();
      resetStats();
      onClose();
    }
  }, [isSuccess, onClose]);

  return (
    <Modal size={'xl'} variant={'brand'} isOpen={open} onClose={onClose} isCentered>
      <ModalOverlay />
      <ModalContent>
        <ModalHeader>
          <ProgressStepper stepIdx={activeStep} steps={steps} />
        </ModalHeader>
        <ModalCloseButton />
        <ModalBody>
          <Flex direction={'column'}>
            { activeStep === 0 && (
                <ApproveAllowance
                  tokenAddress={vaultV1Address}
                  allowanceFor={migratorAddress}
                  amount={migrationAmount}
                  step={activeStep}
                  validateStep={goToNext}
                  address={address!}
                />
            )}
            { activeStep === 1 && (
              <Button
                my={5}
                onClick={migrate}
                disabled={isLoading}
                backgroundColor={useColorModeValue('brand.primary.200', 'brand.primary.300')}
                _hover={{ bgColor: useColorModeValue('brand.primary.300', 'brand.primary.100') }}
                color={useColorModeValue('#00cf6f', 'inherit')}>
                {isLoading ? <Spinner /> : 'Migrate'}
              </Button>
            )}
          </Flex>
        </ModalBody>
      </ModalContent>
    </Modal>
  );
};

MigratePanelModal.defaultProps = {};
