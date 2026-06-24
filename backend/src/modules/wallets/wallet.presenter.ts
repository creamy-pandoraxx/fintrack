import type { Wallet } from "@prisma/client";

export const presentWallet = (wallet: Wallet) => ({
  ...wallet,
  initialBalance: wallet.initialBalance.toNumber(),
  currentBalance: wallet.currentBalance.toNumber()
});

export const presentWallets = (wallets: Wallet[]) => wallets.map(presentWallet);
