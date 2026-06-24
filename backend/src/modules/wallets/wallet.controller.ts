import type { RequestHandler } from "express";

import { successResponse } from "../../utils/api-response";
import { asyncHandler } from "../../utils/async-handler";
import { getRequestAuth } from "../../utils/request-auth";
import {
  archiveWallet,
  createWallet,
  getWalletById,
  listWallets,
  updateWallet
} from "./wallet.service";
import type { CreateWalletInput, UpdateWalletInput } from "./wallet.schema";
import { presentWallet, presentWallets } from "./wallet.presenter";

export const listWalletsController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const wallets = await listWallets(auth.firebaseUid);

    return res
      .status(200)
      .json(successResponse("Wallets retrieved successfully", presentWallets(wallets)));
  }
);

export const createWalletController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const wallet = await createWallet(
      auth.firebaseUid,
      req.body as CreateWalletInput
    );

    return res
      .status(201)
      .json(successResponse("Wallet created successfully", presentWallet(wallet)));
  }
);

export const getWalletByIdController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const wallet = await getWalletById(auth.firebaseUid, req.params.id);

    return res
      .status(200)
      .json(successResponse("Wallet retrieved successfully", presentWallet(wallet)));
  }
);

export const updateWalletController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const wallet = await updateWallet(
      auth.firebaseUid,
      req.params.id,
      req.body as UpdateWalletInput
    );

    return res
      .status(200)
      .json(successResponse("Wallet updated successfully", presentWallet(wallet)));
  }
);

export const archiveWalletController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    await archiveWallet(auth.firebaseUid, req.params.id);

    return res
      .status(200)
      .json(successResponse<null>("Wallet archived successfully", null));
  }
);
