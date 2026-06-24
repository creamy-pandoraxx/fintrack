import type { RequestHandler } from "express";

import { successResponse } from "../../utils/api-response";
import { asyncHandler } from "../../utils/async-handler";
import { getRequestAuth } from "../../utils/request-auth";
import { createActivityFeedEvent } from "../firestore/firestore.service";
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

type ActivityTransaction = Awaited<ReturnType<typeof createTransaction>>;

const createTransactionActivity = async (
  firebaseUid: string,
  type: "transaction_created" | "transaction_updated" | "transaction_deleted",
  transaction: ActivityTransaction
) => {
  const action =
    type === "transaction_created"
      ? "Added"
      : type === "transaction_updated"
        ? "Updated"
        : "Deleted";
  const transactionLabel =
    transaction.type === "EXPENSE" ? "expense" : "income";

  try {
    await createActivityFeedEvent(firebaseUid, {
      type,
      title: `${action} ${transactionLabel}`,
      message: `${transaction.category.name} - ${transaction.amount.toNumber()}`,
      amount: transaction.amount.toNumber(),
      transactionType: transaction.type,
      categoryName: transaction.category.name,
      walletName: transaction.wallet.name
    });
  } catch (error) {
    console.error("Failed to create Firestore activity feed event", error);
  }
};

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
    await createTransactionActivity(
      auth.firebaseUid,
      "transaction_created",
      transaction
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
    await createTransactionActivity(
      auth.firebaseUid,
      "transaction_updated",
      transaction
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
    const transaction = await deleteTransaction(auth.firebaseUid, req.params.id);
    await createTransactionActivity(
      auth.firebaseUid,
      "transaction_deleted",
      transaction
    );

    return res
      .status(200)
      .json(successResponse<null>("Transaction deleted successfully", null));
  }
);
