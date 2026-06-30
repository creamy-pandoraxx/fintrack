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

export const deleteUserActivityFeed = async (firebaseUid: string) => {
  const firestore = getFirebaseFirestore();
  const userDocument = firestore.collection("users").doc(firebaseUid);
  const activityFeed = userDocument.collection("activity_feed");

  while (true) {
    const snapshot = await activityFeed.limit(500).get();
    if (snapshot.empty) {
      break;
    }

    const batch = firestore.batch();
    snapshot.docs.forEach((document) => batch.delete(document.ref));
    await batch.commit();
  }

  await userDocument.delete();
};
