import { prisma } from "../../config/prisma";
import { HttpError } from "../../utils/http-error";
import type { UpdateUserInput } from "./user.schema";

export const getCurrentUser = async (firebaseUid: string) => {
  const user = await prisma.user.findUnique({
    where: { firebaseUid }
  });

  if (!user) {
    throw new HttpError(404, "User profile not found");
  }

  return user;
};

export const updateCurrentUser = async (
  firebaseUid: string,
  input: UpdateUserInput
) => {
  const existingUser = await prisma.user.findUnique({
    where: { firebaseUid }
  });

  if (!existingUser) {
    throw new HttpError(404, "User profile not found");
  }

  return prisma.user.update({
    where: { firebaseUid },
    data: input
  });
};
