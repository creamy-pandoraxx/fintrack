import { TransactionType } from "@prisma/client";

export const defaultCategories = [
  {
    name: "Salary",
    type: TransactionType.INCOME,
    icon: "salary",
    color: "#22C55E",
    isDefault: true
  },
  {
    name: "Freelance",
    type: TransactionType.INCOME,
    icon: "briefcase",
    color: "#14B8A6",
    isDefault: true
  },
  {
    name: "Gift",
    type: TransactionType.INCOME,
    icon: "gift",
    color: "#A855F7",
    isDefault: true
  },
  {
    name: "Investment",
    type: TransactionType.INCOME,
    icon: "trending-up",
    color: "#3B82F6",
    isDefault: true
  },
  {
    name: "Other",
    type: TransactionType.INCOME,
    icon: "more-horizontal",
    color: "#64748B",
    isDefault: true
  },
  {
    name: "Food",
    type: TransactionType.EXPENSE,
    icon: "utensils",
    color: "#F97316",
    isDefault: true
  },
  {
    name: "Transport",
    type: TransactionType.EXPENSE,
    icon: "car",
    color: "#06B6D4",
    isDefault: true
  },
  {
    name: "Shopping",
    type: TransactionType.EXPENSE,
    icon: "shopping-bag",
    color: "#EC4899",
    isDefault: true
  },
  {
    name: "Bills",
    type: TransactionType.EXPENSE,
    icon: "receipt",
    color: "#EAB308",
    isDefault: true
  },
  {
    name: "Health",
    type: TransactionType.EXPENSE,
    icon: "heart-pulse",
    color: "#EF4444",
    isDefault: true
  },
  {
    name: "Education",
    type: TransactionType.EXPENSE,
    icon: "graduation-cap",
    color: "#6366F1",
    isDefault: true
  },
  {
    name: "Entertainment",
    type: TransactionType.EXPENSE,
    icon: "film",
    color: "#8B5CF6",
    isDefault: true
  },
  {
    name: "Other",
    type: TransactionType.EXPENSE,
    icon: "more-horizontal",
    color: "#64748B",
    isDefault: true
  }
] as const;
