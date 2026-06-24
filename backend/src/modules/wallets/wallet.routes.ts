import { Router } from "express";

import { authMiddleware } from "../../middleware/auth.middleware";
import { validateBody } from "../../middleware/validate.middleware";
import {
  archiveWalletController,
  createWalletController,
  getWalletByIdController,
  listWalletsController,
  updateWalletController
} from "./wallet.controller";
import { createWalletSchema, updateWalletSchema } from "./wallet.schema";

export const walletRouter = Router();

walletRouter.use(authMiddleware);

walletRouter.get("/wallets", listWalletsController);
walletRouter.post(
  "/wallets",
  validateBody(createWalletSchema),
  createWalletController
);
walletRouter.get("/wallets/:id", getWalletByIdController);
walletRouter.patch(
  "/wallets/:id",
  validateBody(updateWalletSchema),
  updateWalletController
);
walletRouter.delete("/wallets/:id", archiveWalletController);
