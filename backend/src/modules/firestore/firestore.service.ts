import { FieldValue } from "firebase-admin/firestore";

import { getFirebaseFirestore } from "../../config/firebase";

export type ActivityFeedEventType =
  | "transaction_created"
  | "transaction_updated"
  | "transaction_deleted"
  | "budget_created"
  | "budget_updated"
  | "wallet_created";

export type CreateActivityFeedEventInput = {
  type: ActivityFeedEventType;
  title: string;
  message: string;
  amount?: number;
  transactionType?: "INCOME" | "EXPENSE";
  categoryName?: string;
  walletName?: string;
};

export const createActivityFeedEvent = async (
  firebaseUid: string,
  input: CreateActivityFeedEventInput
) => {
  await getFirebaseFirestore()
    .collection("users")
    .doc(firebaseUid)
    .collection("activity_feed")
    .add({
      ...input,
      createdAt: FieldValue.serverTimestamp()
    });
};
