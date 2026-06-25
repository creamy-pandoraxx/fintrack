import { Prisma } from "@prisma/client";

import { prisma } from "../../config/prisma";
import { HttpError } from "../../utils/http-error";
import { getCurrentUser } from "../users/user.service";
import type { CreateWalletInput, UpdateWalletInput } from "./wallet.schema";

const findActiveWalletForUser = async (firebaseUid: string, walletId: string) => {
  const wallet = await prisma.wallet.findFirst({
    where: {
      id: walletId,
      isArchived: false,
      user: {
        firebaseUid
      }
    }
  });

  if (!wallet) {
    throw new HttpError(404, "Wallet not found");
  }

  return wallet;
};

export const listWallets = async (firebaseUid: string) => {
  return prisma.wallet.findMany({
    where: {
      isArchived: false,
      user: {
        firebaseUid
      }
    },
    orderBy: {
      createdAt: "desc"
    }
  });
};

export const createWallet = async (
  firebaseUid: string,
  input: CreateWalletInput
) => {
  const user = await getCurrentUser(firebaseUid);
  const initialBalance = new Prisma.Decimal(input.initialBalance);

  return prisma.wallet.create({
    data: {
      userId: user.id,
      name: input.name,
      type: input.type,
      initialBalance,
      currentBalance: initialBalance,
      currency: input.currency
    }
  });
};

export const getWalletById = async (firebaseUid: string, walletId: string) => {
  return findActiveWalletForUser(firebaseUid, walletId);
};

export const updateWallet = async (
  firebaseUid: string,
  walletId: string,
  input: UpdateWalletInput
) => {
  const wallet = await findActiveWalletForUser(firebaseUid, walletId);
  const data: Prisma.WalletUpdateInput = {
    name: input.name,
    type: input.type,
    currency: input.currency
  };

  if (input.initialBalance !== undefined) {
    const initialBalance = new Prisma.Decimal(input.initialBalance);
    const balanceDelta = initialBalance.minus(wallet.initialBalance);

    data.initialBalance = initialBalance;
    data.currentBalance = wallet.currentBalance.plus(balanceDelta);
  }

  return prisma.wallet.update({
    where: {
      id: walletId
    },
    data
  });
};

export const archiveWallet = async (firebaseUid: string, walletId: string) => {
  await findActiveWalletForUser(firebaseUid, walletId);

  return prisma.wallet.update({
    where: {
      id: walletId
    },
    data: {
      isArchived: true
    }
  });
};
