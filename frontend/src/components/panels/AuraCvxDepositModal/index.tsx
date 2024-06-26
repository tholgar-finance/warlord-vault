import { FC, useCallback, useEffect, useMemo } from 'react';
import { Button, Flex, Spinner, useColorModeValue } from '@chakra-ui/react';
import { useContractWrite, useWaitForTransaction } from 'wagmi';
import { auraAddress, cvxAddress, zapAddress, zapperABI } from '../../../config/blockchain';
import { useStore } from '../../../store';
import { ApproveAllowance } from '../../blockchain/ApproveAllowance/Index';
import useConnectedAccount from '../../../hooks/useConnectedAccount';

export interface AuraCvxDepositModalProps {
  step: number;
  validateStep: () => void;
}

interface DepositStepProps {
  validateStep: () => void;
  address: `0x${string}`;
  multiToken: boolean;
  tokenAddresses: `0x${string}`[];
  depositAmounts: bigint[];
}

const DepositStep: FC<DepositStepProps> = ({
  validateStep,
  address,
  multiToken,
  tokenAddresses,
  depositAmounts
}) => {
  const { data, write } = useContractWrite({
    address: zapAddress,
    abi: zapperABI,
    functionName: multiToken ? 'zapVlTokens' : 'zapVlToken'
  });
  const { isLoading, isSuccess } = useWaitForTransaction({
    hash: data?.hash
  });
  const deposit = useCallback(() => {
    if (!isLoading && !isSuccess) {
      write({
        args: [
          multiToken ? tokenAddresses : tokenAddresses[0],
          multiToken ? depositAmounts : depositAmounts[0],
          address
        ]
      });
    }
  }, [isLoading, isSuccess, multiToken, tokenAddresses, depositAmounts, address]);

  useEffect(() => {
    if (isSuccess) {
      validateStep();
    }
  }, [isSuccess]);

  return (
    <Flex direction={'column'}>
      <Button
        my={5}
        onClick={deposit}
        disabled={isLoading}
        backgroundColor={useColorModeValue('brand.primary.200', 'brand.primary.300')}
        _hover={{ bgColor: useColorModeValue('brand.primary.300', 'brand.primary.100') }}
        color={useColorModeValue('#00cf6f', 'inherit')}>
        {isLoading ? <Spinner /> : 'Deposit'}
      </Button>
    </Flex>
  );
};

export const AuraCvxDepositModal: FC<AuraCvxDepositModalProps> = ({ step, validateStep }) => {
  const { address } = useConnectedAccount();
  const auraDepositInputAmount = useStore((state) => state.getDepositInputTokenAmount('aura'));
  const cvxDepositInputAmount = useStore((state) => state.getDepositInputTokenAmount('cvx'));
  const stepsComponents = useMemo(() => {
    let components = [];
    let tokenAddresses: `0x${string}`[] = [];
    let depositAmounts = [];

    if (auraDepositInputAmount > 0) {
      tokenAddresses.push(auraAddress);
      depositAmounts.push(auraDepositInputAmount);
      components.push(
        <ApproveAllowance
          token={'aura'}
          key={'aura'}
          tokenAddress={auraAddress}
          step={step}
          allowanceFor={zapAddress}
          validateStep={validateStep}
          address={address!}
        />
      );
    }
    if (cvxDepositInputAmount > 0) {
      tokenAddresses.push(cvxAddress);
      depositAmounts.push(cvxDepositInputAmount);
      components.push(
        <ApproveAllowance
          token={'cvx'}
          key={'cvx'}
          tokenAddress={cvxAddress}
          step={step}
          allowanceFor={zapAddress}
          validateStep={validateStep}
          address={address!}
        />
      );
    }
    components.push(
      <DepositStep
        validateStep={validateStep}
        address={address!}
        multiToken={auraDepositInputAmount > 0n && cvxDepositInputAmount > 0n}
        tokenAddresses={tokenAddresses}
        depositAmounts={depositAmounts}
      />
    );
    return components;
  }, [auraDepositInputAmount, cvxDepositInputAmount, step, validateStep]);

  return stepsComponents[step];
};

AuraCvxDepositModal.defaultProps = {};
