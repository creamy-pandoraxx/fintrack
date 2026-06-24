import { Prisma } from "@prisma/client";

import { prisma } from "../../config/prisma";
import { defaultCategories } from "./default-categories";
import type { SyncUserInput } from "./auth.schema";

type SyncUserParams = {
  firebaseUid: string;
  email: string;
  input: SyncUserInput;
};

export const syncUser = async ({ firebaseUid, email, input }: SyncUserParams) => {
  const existingUser = await prisma.user.findUnique({
    where: { firebaseUid }
  });

  if (existingUser) {
    return existingUser;
  }

  try {
    return await prisma.user.create({
      data: {
        firebaseUid,
        email,
        name: input.name,
        categories: {
          create: defaultCategories.map((category) => ({ ...category }))
        }
      }
    });
  } catch (error) {
    if (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === "P2002"
    ) {
      const user = await prisma.user.findUnique({
        where: { firebaseUid }
      });

      if (user) {
        return user;
      }
    }

    throw error;
  }
};
