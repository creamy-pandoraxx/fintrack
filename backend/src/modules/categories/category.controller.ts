import type { RequestHandler } from "express";

import { successResponse } from "../../utils/api-response";
import { asyncHandler } from "../../utils/async-handler";
import { getRequestAuth } from "../../utils/request-auth";
import type {
  CreateCategoryInput,
  ListCategoriesQuery,
  UpdateCategoryInput
} from "./category.schema";
import {
  createCategory,
  deleteCategory,
  listCategories,
  updateCategory
} from "./category.service";

export const listCategoriesController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const categories = await listCategories(
      auth.firebaseUid,
      req.query as ListCategoriesQuery
    );

    return res
      .status(200)
      .json(successResponse("Categories retrieved successfully", categories));
  }
);

export const createCategoryController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const category = await createCategory(
      auth.firebaseUid,
      req.body as CreateCategoryInput
    );

    return res
      .status(201)
      .json(successResponse("Category created successfully", category));
  }
);

export const updateCategoryController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    const category = await updateCategory(
      auth.firebaseUid,
      req.params.id,
      req.body as UpdateCategoryInput
    );

    return res
      .status(200)
      .json(successResponse("Category updated successfully", category));
  }
);

export const deleteCategoryController: RequestHandler = asyncHandler(
  async (req, res) => {
    const auth = getRequestAuth(req);
    await deleteCategory(auth.firebaseUid, req.params.id);

    return res
      .status(200)
      .json(successResponse<null>("Category deleted successfully", null));
  }
);
