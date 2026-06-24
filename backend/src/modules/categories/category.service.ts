import { prisma } from "../../config/prisma";
import { HttpError } from "../../utils/http-error";
import { getCurrentUser } from "../users/user.service";
import type {
  CreateCategoryInput,
  ListCategoriesQuery,
  UpdateCategoryInput
} from "./category.schema";

const findCategoryForUser = async (firebaseUid: string, categoryId: string) => {
  const category = await prisma.category.findFirst({
    where: {
      id: categoryId,
      user: {
        firebaseUid
      }
    }
  });

  if (!category) {
    throw new HttpError(404, "Category not found");
  }

  return category;
};

export const listCategories = async (
  firebaseUid: string,
  query: ListCategoriesQuery
) => {
  return prisma.category.findMany({
    where: {
      type: query.type,
      user: {
        firebaseUid
      }
    },
    orderBy: [
      {
        isDefault: "desc"
      },
      {
        createdAt: "asc"
      }
    ]
  });
};

export const createCategory = async (
  firebaseUid: string,
  input: CreateCategoryInput
) => {
  const user = await getCurrentUser(firebaseUid);

  return prisma.category.create({
    data: {
      userId: user.id,
      name: input.name,
      type: input.type,
      icon: input.icon,
      color: input.color,
      isDefault: false
    }
  });
};

export const updateCategory = async (
  firebaseUid: string,
  categoryId: string,
  input: UpdateCategoryInput
) => {
  await findCategoryForUser(firebaseUid, categoryId);

  return prisma.category.update({
    where: {
      id: categoryId
    },
    data: input
  });
};

export const deleteCategory = async (
  firebaseUid: string,
  categoryId: string
) => {
  await findCategoryForUser(firebaseUid, categoryId);

  const transactionCount = await prisma.transaction.count({
    where: {
      categoryId,
      user: {
        firebaseUid
      }
    }
  });

  if (transactionCount > 0) {
    throw new HttpError(409, "Category cannot be deleted because it has transactions");
  }

  await prisma.category.delete({
    where: {
      id: categoryId
    }
  });
};
