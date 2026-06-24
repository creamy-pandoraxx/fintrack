import type { RequestHandler } from "express";

import { successResponse } from "../../utils/api-response";
import { asyncHandler } from "../../utils/async-handler";
import { getRequestAuth } from "../../utils/request-auth";
import {
  createTransaction,
  deleteTransaction,
  getTransactionById,
  listTransactions,
  updateTransaction
} from "./transaction.service";
import type {
  CreateTransactionInput,
  ListTransactionsQuery,
  UpdateTransactionInput
} from "./transaction.schema";
import {
  presentTransaction,
  presentTransactions
} from "./transaction.presenter";

export const listTransactionsController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const result = await listTransactions(
      auth.firebaseUid,
      req.query as unknown as ListTransactionsQuery
    );

    return res.status(200).json(
      successResponse("Transactions retrieved successfully", {
        items: presentTransactions(result.items),
        pagination: result.pagination
      })
    );
  }
);

export const createTransactionController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const transaction = await createTransaction(
      auth.firebaseUid,
      req.body as CreateTransactionInput
    );

    return res
      .status(201)
      .json(
        successResponse(
          "Transaction created successfully",
          presentTransaction(transaction)
        )
      );
  }
);

export const getTransactionByIdController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const transaction = await getTransactionById(auth.firebaseUid, req.params.id);

    return res
      .status(200)
      .json(
        successResponse(
          "Transaction retrieved successfully",
          presentTransaction(transaction)
        )
      );
  }
);

export const updateTransactionController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const transaction = await updateTransaction(
      auth.firebaseUid,
      req.params.id,
      req.body as UpdateTransactionInput
    );

    return res
      .status(200)
      .json(
        successResponse(
          "Transaction updated successfully",
          presentTransaction(transaction)
        )
      );
  }
);

export const deleteTransactionController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    await deleteTransaction(auth.firebaseUid, req.params.id);

    return res
      .status(200)
      .json(successResponse<null>("Transaction deleted successfully", null));
  }
);
