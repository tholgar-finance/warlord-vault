import { FC, useCallback, useEffect, useMemo } from 'react';
import {
  Button,
  Flex,
  Modal,
  ModalBody,
  ModalCloseButton,
  ModalContent,
  ModalHeader,
  ModalOverlay,
  Spinner,
  useColorModeValue,
  useSteps
} from '@chakra-ui/react';
import { ProgressStepper } from '../../ui/ProgressStepper';
import { useStore } from '../../../store';
import { Address, useContractWrite, useWaitForTransaction } from 'wagmi';
import { vaultABI } from '../../../config/blockchain';
import useConnectedAccount from '../../../hooks/useConnectedAccount';

export interface WithdrawPanelModalProps {
  vaultAddress: Address;
  open: boolean;
  onClose: () => void;
  inputToken: 'thWAR' | 'tWAR';
}

export const WithdrawPanelModal: FC<WithdrawPanelModalProps> = ({ vaultAddress, open, onClose, inputToken }) => {
  const withdrawToken = useStore((state) => state.withdrawToken);
  const wstkWARWithdrawInputAmount = useStore((state) => state.getWithdrawInputTokenAmount(inputToken));
  const resetBalances = useStore((state) => state.resetBalances);
  const { address } = useConnectedAccount();
  const { data, write } = useContractWrite({
    address: vaultAddress,
    abi: vaultABI,
    functionName: 'redeem'
  });

  const { isLoading, isSuccess } = useWaitForTransaction({
    hash: data?.hash
  });
  const withdraw = useCallback(() => {
    if (!isLoading && !isSuccess) {
      write({
        args: [wstkWARWithdrawInputAmount, address, address]
      });
    }
  }, [wstkWARWithdrawInputAmount, address]);
  const steps = useMemo(() => {
    if (withdrawToken != 'war') {
      return [
        {
          label: 'Withdraw',
          description: 'Withdraw tokens'
        }
      ];
    }
    return [
      {
        label: 'Withdraw',
        description: 'Withdraw WAR'
      }
    ];
  }, [withdrawToken]);
  const { activeStep } = useSteps({
    index: 0,
    count: steps.length
  });

  useEffect(() => {
    if (isSuccess) {
      resetBalances();
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
            <Button
              my={5}
              onClick={withdraw}
              disabled={isLoading}
              backgroundColor={useColorModeValue('brand.primary.200', 'brand.primary.300')}
              _hover={{ bgColor: useColorModeValue('brand.primary.300', 'brand.primary.100') }}
              color={useColorModeValue('#00cf6f', 'inherit')}>
              {isLoading ? <Spinner /> : 'Withdraw'}
            </Button>
          </Flex>
        </ModalBody>
      </ModalContent>
    </Modal>
  );
};

WithdrawPanelModal.defaultProps = {};
