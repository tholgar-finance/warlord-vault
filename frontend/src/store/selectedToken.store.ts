import { StateCreator } from 'zustand';
import { Store } from './index';

export type tokensSelection = 'war' | 'aura/cvx' | 'eth' | 'weth';
export interface SelectedTokenStore {
  depositToken: tokensSelection;
  singleDepositToken: tokensSelection;
  withdrawToken: tokensSelection;
  setDepositToken: (token: tokensSelection) => void;
  setSingleDepositToken: (token: tokensSelection) => void;
  setWithdrawToken: (token: tokensSelection) => void;
}

export const createSelectedTokenStore: StateCreator<Store, [], [], SelectedTokenStore> = (set) => ({
  depositToken: 'eth',
  singleDepositToken: 'eth',
  withdrawToken: 'war',
  setDepositToken: (token: tokensSelection) =>
    set((state: Store) => ({ ...state, depositToken: token })),
  setSingleDepositToken: (token: tokensSelection) =>
    set((state: Store) => ({ ...state, singleDepositToken: token })),
  setWithdrawToken: (token: tokensSelection) =>
    set((state: Store) => ({ ...state, withdrawToken: token }))
});
