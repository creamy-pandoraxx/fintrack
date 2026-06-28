\\\\# API Specification — FinTrack



\\\\## 1. Base URL



```txt

/api/v1

````



Local example:



```txt

http://localhost:3000/api/v1

```



\## 2. Authentication



All protected endpoints require Firebase ID Token.



Header:



```txt

Authorization: Bearer <firebase\\\\\\\_id\\\\\\\_token>

```



Backend must verify token using Firebase Admin SDK.



Backend must get identity from verified token:



\* firebaseUid

\* email



Backend must not trust `userId` from request body.



\## 3. Standard Response Format



\### 3.1 Success Response



```json

{

\\\&#x20; "success": true,

\\\&#x20; "message": "Success message",

\\\&#x20; "data": {}

}

```



\### 3.2 Error Response



```json

{

\\\&#x20; "success": false,

\\\&#x20; "message": "Error message",

\\\&#x20; "errors": \\\\\\\[]

}

```



\## 4. Common HTTP Status Codes



| Code | Meaning               |

| ---- | --------------------- |

| 200  | OK                    |

| 201  | Created               |

| 400  | Bad Request           |

| 401  | Unauthorized          |

| 403  | Forbidden             |

| 404  | Not Found             |

| 409  | Conflict              |

| 422  | Validation Error      |

| 500  | Internal Server Error |



\## 5. Auth Endpoints



\### 5.1 POST /auth/sync



Purpose:



Create or sync user profile after Firebase login/register.



Protected:



Yes.



Request:



```json

{

\\\&#x20; "name": "Jek"

}

```



Behavior:



\* Verify Firebase token.

\* Extract firebaseUid and email from token.

\* If user exists, return existing user.

\* If user does not exist, create user.

\* If new user, generate default categories.



Response:



```json

{

\\\&#x20; "success": true,

\\\&#x20; "message": "User synced successfully",

\\\&#x20; "data": {

\\\&#x20;   "id": "uuid",

\\\&#x20;   "firebaseUid": "firebase\\\\\\\_uid",

\\\&#x20;   "email": "user@email.com",

\\\&#x20;   "name": "Jek",

\\\&#x20;   "photoUrl": null,

\\\&#x20;   "createdAt": "2026-06-24T00:00:00.000Z",

\\\&#x20;   "updatedAt": "2026-06-24T00:00:00.000Z"

\\\&#x20; }

}

```



Validation:



\* name optional

\* if provided, name must be string



\## 6. User Endpoints



\### 6.1 GET /users/me



Purpose:



Get current authenticated user profile.



Protected:



Yes.



Response:



```json

{

\\\&#x20; "success": true,

\\\&#x20; "message": "User profile retrieved successfully",

\\\&#x20; "data": {

\\\&#x20;   "id": "uuid",

\\\&#x20;   "firebaseUid": "firebase\\\\\\\_uid",

\\\&#x20;   "email": "user@email.com",

\\\&#x20;   "name": "Jek",

\\\&#x20;   "photoUrl": null

\\\&#x20; }

}

```



\### 6.2 PATCH /users/me



Purpose:



Update current user profile.



Protected:



Yes.



Request:



```json

{

\\\&#x20; "name": "Jek",

\\\&#x20; "photoUrl": "https://example.com/avatar.jpg"

}

```



Response:



```json

{

\\\&#x20; "success": true,

\\\&#x20; "message": "User profile updated successfully",

\\\&#x20; "data": {

\\\&#x20;   "id": "uuid",

\\\&#x20;   "email": "user@email.com",

\\\&#x20;   "name": "Jek",

\\\&#x20;   "photoUrl": "https://example.com/avatar.jpg"

\\\&#x20; }

}

```



Validation:



\* name optional string

\* photoUrl optional string or null



\## 7. Wallet Endpoints



\### 7.1 GET /wallets



Purpose:



Get all active wallets for authenticated user.



Protected:



Yes.



Response:



```json

{

\\\&#x20; "success": true,

\\\&#x20; "message": "Wallets retrieved successfully",

\\\&#x20; "data": \\\\\\\[

\\\&#x20;   {

\\\&#x20;     "id": "uuid",

\\\&#x20;     "name": "Cash",

\\\&#x20;     "type": "cash",

\\\&#x20;     "initialBalance": 100000,

\\\&#x20;     "currentBalance": 150000,

\\\&#x20;     "currency": "IDR",

\\\&#x20;     "isArchived": false

\\\&#x20;   }

\\\&#x20; ]

}

```



\### 7.2 POST /wallets



Purpose:



Create wallet.



Protected:



Yes.



Request:



```json

{

\\\&#x20; "name": "Cash",

\\\&#x20; "type": "cash",

\\\&#x20; "initialBalance": 100000,

\\\&#x20; "currency": "IDR"

}

```



Behavior:



\* currentBalance is equal to initialBalance on create.

\* wallet belongs to authenticated user.



Response:



```json

{

\\\&#x20; "success": true,

\\\&#x20; "message": "Wallet created successfully",

\\\&#x20; "data": {

\\\&#x20;   "id": "uuid",

\\\&#x20;   "name": "Cash",

\\\&#x20;   "type": "cash",

\\\&#x20;   "initialBalance": 100000,

\\\&#x20;   "currentBalance": 100000,

\\\&#x20;   "currency": "IDR"

\\\&#x20; }

}

```



Validation:



\* name required

\* type required

\* initialBalance required number

\* currency optional, default IDR



\### 7.3 GET /wallets/:id



Purpose:



Get wallet detail.



Protected:



Yes.



Rules:



\* Wallet must belong to authenticated user.



\### 7.4 PATCH /wallets/:id



Purpose:



Update wallet.



Protected:



Yes.



Request:



```json

{

\\\&#x20; "name": "Main Cash",

\\\&#x20; "type": "cash",

\\\&#x20; "initialBalance": 200000,

\\\&#x20; "currency": "IDR"

}

```



Rules:



\* Wallet must belong to authenticated user.

\* If initialBalance changes, currentBalance is adjusted by the initial balance delta.



\### 7.5 DELETE /wallets/:id



Purpose:



Archive wallet.



Protected:



Yes.



Behavior:



\* Use soft delete.

\* Set isArchived to true.

\* Do not physically delete wallet.



Response:



```json

{

\\\&#x20; "success": true,

\\\&#x20; "message": "Wallet archived successfully",

\\\&#x20; "data": null

}

```



\## 8. Category Endpoints



\### 8.1 GET /categories



Purpose:



Get categories for current user.



Protected:



Yes.



Query params:



```txt

type=INCOME

type=EXPENSE

```



Response:



```json

{

\\\&#x20; "success": true,

\\\&#x20; "message": "Categories retrieved successfully",

\\\&#x20; "data": \\\\\\\[

\\\&#x20;   {

\\\&#x20;     "id": "uuid",

\\\&#x20;     "name": "Food",

\\\&#x20;     "type": "EXPENSE",

\\\&#x20;     "icon": "food",

\\\&#x20;     "color": "#22C55E",

\\\&#x20;     "isDefault": true

\\\&#x20;   }

\\\&#x20; ]

}

```



\### 8.2 POST /categories



Purpose:



Create custom category.



Protected:



Yes.



Request:



```json

{

\\\&#x20; "name": "Coffee",

\\\&#x20; "type": "EXPENSE",

\\\&#x20; "icon": "coffee",

\\\&#x20; "color": "#8B5CF6"

}

```



Validation:



\* name required

\* type required, INCOME or EXPENSE

\* icon optional

\* color optional



\### 8.3 PATCH /categories/:id



Purpose:



Update category.



Protected:



Yes.



Request:



```json

{

\\\&#x20; "name": "Coffee \\\\\\\& Drinks",

\\\&#x20; "icon": "coffee",

\\\&#x20; "color": "#A855F7"

}

```



Rules:



\* Category must belong to authenticated user.

\* System/default category may be protected if needed.



\### 8.4 DELETE /categories/:id



Purpose:



Delete category.



Protected:



Yes.



Rules:



\* Category must belong to authenticated user.

\* Category cannot be deleted if it has transactions.

\* Default category can be protected from deletion.



\## 9. Transaction Endpoints



\### 9.1 GET /transactions



Purpose:



Get paginated transaction list.



Protected:



Yes.



Query params:



```txt

type=INCOME or EXPENSE

walletId=uuid

categoryId=uuid

startDate=YYYY-MM-DD

endDate=YYYY-MM-DD

search=keyword

page=1

limit=20

```



Response:



```json

{

\\\&#x20; "success": true,

\\\&#x20; "message": "Transactions retrieved successfully",

\\\&#x20; "data": {

\\\&#x20;   "items": \\\\\\\[

\\\&#x20;     {

\\\&#x20;       "id": "uuid",

\\\&#x20;       "type": "EXPENSE",

\\\&#x20;       "amount": 50000,

\\\&#x20;       "title": "Lunch",

\\\&#x20;       "note": "Nasi ayam",

\\\&#x20;       "transactionDate": "2026-06-24T00:00:00.000Z",

\\\&#x20;       "wallet": {

\\\&#x20;         "id": "uuid",

\\\&#x20;         "name": "Cash"

\\\&#x20;       },

\\\&#x20;       "category": {

\\\&#x20;         "id": "uuid",

\\\&#x20;         "name": "Food",

\\\&#x20;         "icon": "food",

\\\&#x20;         "color": "#22C55E"

\\\&#x20;       }

\\\&#x20;     }

\\\&#x20;   ],

\\\&#x20;   "pagination": {

\\\&#x20;     "page": 1,

\\\&#x20;     "limit": 20,

\\\&#x20;     "total": 100,

\\\&#x20;     "totalPages": 5

\\\&#x20;   }

\\\&#x20; }

}

```



\### 9.2 POST /transactions



Purpose:



Create transaction.



Protected:



Yes.



Request:



```json

{

\\\&#x20; "walletId": "uuid",

\\\&#x20; "categoryId": "uuid",

\\\&#x20; "type": "EXPENSE",

\\\&#x20; "amount": 50000,

\\\&#x20; "title": "Lunch",

\\\&#x20; "note": "Nasi ayam",

\\\&#x20; "transactionDate": "2026-06-24"

}

```



Validation:



\* walletId required

\* categoryId required

\* type required, INCOME or EXPENSE

\* amount required and greater than 0

\* title required

\* note optional

\* transactionDate required and valid date



Rules:



\* Wallet must belong to authenticated user.

\* Category must belong to authenticated user.

\* Category type must match transaction type.

\* Income increases wallet balance.

\* Expense decreases wallet balance.

\* Operation must use database transaction.

\* Create Firestore activity event after success.



Response:



```json

{

\\\&#x20; "success": true,

\\\&#x20; "message": "Transaction created successfully",

\\\&#x20; "data": {

\\\&#x20;   "id": "uuid",

\\\&#x20;   "type": "EXPENSE",

\\\&#x20;   "amount": 50000,

\\\&#x20;   "title": "Lunch",

\\\&#x20;   "note": "Nasi ayam",

\\\&#x20;   "transactionDate": "2026-06-24T00:00:00.000Z"

\\\&#x20; }

}

```



\### 9.3 GET /transactions/:id



Purpose:



Get transaction detail.



Protected:



Yes.



Rules:



\* Transaction must belong to authenticated user.



\### 9.4 PATCH /transactions/:id



Purpose:



Update transaction.



Protected:



Yes.



Request:



```json

{

\\\&#x20; "walletId": "uuid",

\\\&#x20; "categoryId": "uuid",

\\\&#x20; "type": "EXPENSE",

\\\&#x20; "amount": 75000,

\\\&#x20; "title": "Dinner",

\\\&#x20; "note": "Updated note",

\\\&#x20; "transactionDate": "2026-06-24"

}

```



Rules:



\* Transaction must belong to authenticated user.

\* Reverse old transaction effect.

\* Apply new transaction effect.

\* If wallet changes, reverse from old wallet and apply to new wallet.

\* If type changes, handle balance correctly.

\* Operation must use database transaction.

\* Create Firestore activity event after success.



\### 9.5 DELETE /transactions/:id



Purpose:



Delete transaction.



Protected:



Yes.



Rules:



\* Transaction must belong to authenticated user.

\* Reverse wallet balance effect.

\* Operation must use database transaction.

\* Create Firestore activity event after success.



Response:



```json

{

\\\&#x20; "success": true,

\\\&#x20; "message": "Transaction deleted successfully",

\\\&#x20; "data": null

}

```



\## 10. Budget Endpoints



\### 10.1 GET /budgets



Purpose:



Get budgets by month and year.



Protected:



Yes.



Query params:



```txt

month=6

year=2026

```



Response:



```json

{

\\\&#x20; "success": true,

\\\&#x20; "message": "Budgets retrieved successfully",

\\\&#x20; "data": \\\\\\\[

\\\&#x20;   {

\\\&#x20;     "id": "uuid",

\\\&#x20;     "category": {

\\\&#x20;       "id": "uuid",

\\\&#x20;       "name": "Food",

\\\&#x20;       "icon": "food",

\\\&#x20;       "color": "#22C55E"

\\\&#x20;     },

\\\&#x20;     "month": 6,

\\\&#x20;     "year": 2026,

\\\&#x20;     "limitAmount": 1000000,

\\\&#x20;     "usedAmount": 500000,

\\\&#x20;     "remainingAmount": 500000,

\\\&#x20;     "usagePercentage": 50

\\\&#x20;   }

\\\&#x20; ]

}

```



\### 10.2 POST /budgets



Purpose:



Create monthly budget.



Protected:



Yes.



Request:



```json

{

\\\&#x20; "categoryId": "uuid",

\\\&#x20; "month": 6,

\\\&#x20; "year": 2026,

\\\&#x20; "limitAmount": 1000000

}

```



Validation:



\* categoryId required

\* month required, 1 to 12

\* year required

\* limitAmount required and greater than 0



Rules:



\* Category must belong to authenticated user.

\* Category must be EXPENSE.

\* One budget per category per month/year.

\* Duplicate budget should return 409 Conflict.



\### 10.3 PATCH /budgets/:id



Purpose:



Update budget.



Protected:



Yes.



Request:



```json

{

\\\&#x20; "limitAmount": 1200000

}

```



Rules:



\* Budget must belong to authenticated user.

\* limitAmount must be greater than 0.



\### 10.4 DELETE /budgets/:id



Purpose:



Delete budget.



Protected:



Yes.



Rules:



\* Budget must belong to authenticated user.



\## 11. Dashboard Endpoint



\### 11.1 GET /dashboard/summary



Purpose:



Get dashboard summary for selected month and year.



Protected:



Yes.



Query params:



```txt

month=6

year=2026

```



Response:



```json

{

\\\&#x20; "success": true,

\\\&#x20; "message": "Dashboard summary retrieved successfully",

\\\&#x20; "data": {

\\\&#x20;   "totalBalance": 2500000,

\\\&#x20;   "monthlyIncome": 4000000,

\\\&#x20;   "monthlyExpense": 1500000,

\\\&#x20;   "netCashFlow": 2500000,

\\\&#x20;   "monthlyTransactionCount": 12,

\\\&#x20;   "expenseByCategory": \\\\\\\[

\\\&#x20;     {

\\\&#x20;       "categoryId": "uuid",

\\\&#x20;       "categoryName": "Food",

\\\&#x20;       "amount": 500000,

\\\&#x20;       "percentage": 33.3

\\\&#x20;     }

\\\&#x20;   ],

\\\&#x20;   "budgetSummary": \\\\\\\[

\\\&#x20;     {

\\\&#x20;       "budgetId": "uuid",

\\\&#x20;       "categoryName": "Food",

\\\&#x20;       "limitAmount": 1000000,

\\\&#x20;       "usedAmount": 500000,

\\\&#x20;       "remainingAmount": 500000,

\\\&#x20;       "usagePercentage": 50

\\\&#x20;     }

\\\&#x20;   ],

\\\&#x20;   "recentTransactions": \\\\\\\[

\\\&#x20;     {

\\\&#x20;       "id": "uuid",

\\\&#x20;       "type": "EXPENSE",

\\\&#x20;       "amount": 50000,

\\\&#x20;       "title": "Lunch",

\\\&#x20;       "transactionDate": "2026-06-24T00:00:00.000Z",

\\\&#x20;       "wallet": {

\\\&#x20;         "name": "Cash"

\\\&#x20;       },

\\\&#x20;       "category": {

\\\&#x20;         "name": "Food",

\\\&#x20;         "icon": "food",

\\\&#x20;         "color": "#22C55E"

\\\&#x20;       }

\\\&#x20;     }

\\\&#x20;   ]

\\\&#x20; }

}

```



Calculation rules:



\* totalBalance = sum of active wallet currentBalance.

\* monthlyIncome = sum income in selected month/year.

\* monthlyExpense = sum expense in selected month/year.

\* netCashFlow = monthlyIncome - monthlyExpense.

\* monthlyTransactionCount = transaction count in selected month/year.

\* expenseByCategory uses only expense transactions.

\* budgetSummary calculates used amount from transactions.



\## 12. Validation Summary



\### Amount



\* Required.

\* Must be number.

\* Must be greater than 0.

\* Maximum can be 999999999 for MVP.



\### Date



\* Required.

\* Must be valid date.

\* Future date allowed for MVP.



\### Wallet



\* Required for transaction.

\* Must belong to authenticated user.

\* Must not be archived.



\### Category



\* Required for transaction.

\* Must belong to authenticated user.

\* Must match transaction type.



\### Budget



\* Category must be EXPENSE.

\* Month must be 1 to 12.

\* Year must be reasonable.

\* limitAmount must be greater than 0.



\## 13. Error Examples



\### Missing Token



```json

{

\\\&#x20; "success": false,

\\\&#x20; "message": "Unauthorized",

\\\&#x20; "errors": \\\\\\\[]

}

```



\### Validation Error



```json

{

\\\&#x20; "success": false,

\\\&#x20; "message": "Validation failed",

\\\&#x20; "errors": \\\\\\\[

\\\&#x20;   {

\\\&#x20;     "field": "amount",

\\\&#x20;     "message": "Amount must be greater than 0"

\\\&#x20;   }

\\\&#x20; ]

}

```



\### Not Found



```json

{

\\\&#x20; "success": false,

\\\&#x20; "message": "Transaction not found",

\\\&#x20; "errors": \\\\\\\[]

}

```



\### Conflict



```json

{

\\\&#x20; "success": false,

\\\&#x20; "message": "Budget already exists for this category and month",

\\\&#x20; "errors": \\\\\\\[]

}

```



````



\\\\---

