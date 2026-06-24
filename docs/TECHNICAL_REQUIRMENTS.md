\\# Technical Requirements — FinTrack

\\## 1. Overview

FinTrack is a full-stack personal finance tracker application.

The project consists of:

```txt

fintrack/

\&#x20; mobile/

\&#x20; backend/

\&#x20; docs/

````



The mobile app is built with Flutter. The backend is built with Node.js, Express.js, TypeScript, Prisma, and PostgreSQL. Authentication uses Firebase Authentication. Firestore is used only for realtime and semi-structured data, not as the main financial database.



\## 2. Core Architecture Decision



PostgreSQL is the source of truth for financial data.



Firestore is used only for:



\* Activity feed

\* Notification logs

\* Finance tips

\* Remote config or dynamic content



The app must not store primary financial data such as transactions, wallets, budgets, or categories in Firestore.



\## 3. Tech Stack



\### 3.1 Mobile



\* Flutter

\* Dart

\* Riverpod

\* Dio

\* go\_router

\* Firebase Core

\* Firebase Auth

\* Cloud Firestore

\* fl\_chart

\* shared\_preferences

\* optional Hive for local cache



\### 3.2 Backend



\* Node.js

\* TypeScript

\* Express.js

\* Prisma

\* PostgreSQL

\* Firebase Admin SDK

\* Zod

\* Swagger/OpenAPI optional

\* dotenv

\* cors

\* helmet optional

\* morgan optional



\### 3.3 Database



Primary database:



\* PostgreSQL



NoSQL database:



\* Firebase Firestore



Authentication:



\* Firebase Authentication



\## 4. System Architecture



```txt

Flutter Mobile App

\&#x20;       |

\&#x20;       | REST API with Firebase ID Token

\&#x20;       v

Express TypeScript Backend

\&#x20;       |

\&#x20;       | Prisma ORM

\&#x20;       v

PostgreSQL Database



Flutter Mobile App <--> Firebase Auth

Flutter Mobile App <--> Firestore Activity Feed

Backend -----------> Firestore Activity Feed

```



\## 5. Data Ownership



| Data              | Storage    | Reason                         |

| ----------------- | ---------- | ------------------------------ |

| User profile      | PostgreSQL | Relational and stable          |

| Wallets           | PostgreSQL | Financial core data            |

| Categories        | PostgreSQL | Relational data                |

| Transactions      | PostgreSQL | Financial source of truth      |

| Budgets           | PostgreSQL | Relational and analytical      |

| Activity feed     | Firestore  | Realtime and append-only style |

| Notification logs | Firestore  | Semi-structured                |

| Finance tips      | Firestore  | Dynamic content                |

| App config        | Firestore  | Flexible remote data           |



\## 6. Authentication Architecture



Authentication uses Firebase Authentication.



\### Flow



1\. User registers or logs in from Flutter app.

2\. Firebase Auth returns authenticated user.

3\. Flutter retrieves Firebase ID Token.

4\. Flutter sends the token to backend using Authorization header.

5\. Backend verifies token using Firebase Admin SDK.

6\. Backend extracts firebaseUid and email from verified token.

7\. Backend uses firebaseUid to find or create user in PostgreSQL.



\### Authorization Header



```txt

Authorization: Bearer <firebase\\\_id\\\_token>

```



\### Important Security Rules



\* Backend must never trust userId from request body.

\* Backend must always derive user identity from Firebase token.

\* Every database query must be scoped to the authenticated user.

\* Users must not access data from other users.



\## 7. Backend Requirements



\### 7.1 Backend Folder Structure



```txt

backend/

\&#x20; src/

\&#x20;   app.ts

\&#x20;   server.ts

\&#x20;   config/

\&#x20;     env.ts

\&#x20;     firebase.ts

\&#x20;     prisma.ts

\&#x20;   middleware/

\&#x20;     auth.middleware.ts

\&#x20;     error.middleware.ts

\&#x20;     validate.middleware.ts

\&#x20;   modules/

\&#x20;     auth/

\&#x20;       auth.controller.ts

\&#x20;       auth.routes.ts

\&#x20;       auth.service.ts

\&#x20;     users/

\&#x20;       user.controller.ts

\&#x20;       user.routes.ts

\&#x20;       user.service.ts

\&#x20;       user.schema.ts

\&#x20;     wallets/

\&#x20;       wallet.controller.ts

\&#x20;       wallet.routes.ts

\&#x20;       wallet.service.ts

\&#x20;       wallet.schema.ts

\&#x20;     categories/

\&#x20;       category.controller.ts

\&#x20;       category.routes.ts

\&#x20;       category.service.ts

\&#x20;       category.schema.ts

\&#x20;     transactions/

\&#x20;       transaction.controller.ts

\&#x20;       transaction.routes.ts

\&#x20;       transaction.service.ts

\&#x20;       transaction.schema.ts

\&#x20;     budgets/

\&#x20;       budget.controller.ts

\&#x20;       budget.routes.ts

\&#x20;       budget.service.ts

\&#x20;       budget.schema.ts

\&#x20;     dashboard/

\&#x20;       dashboard.controller.ts

\&#x20;       dashboard.routes.ts

\&#x20;       dashboard.service.ts

\&#x20;     firestore/

\&#x20;       firestore.service.ts

\&#x20;   routes/

\&#x20;     index.ts

\&#x20;   utils/

\&#x20;     api-response.ts

\&#x20;     async-handler.ts

\&#x20;     date.ts

\&#x20;     money.ts

\&#x20;     pagination.ts

\&#x20; prisma/

\&#x20;   schema.prisma

\&#x20;   seed.ts

\&#x20; .env.example

\&#x20; package.json

\&#x20; tsconfig.json

\&#x20; README.md

```



\### 7.2 Backend Rules



\* Use TypeScript.

\* Use Express.

\* Use Prisma for database access.

\* Use Zod for request validation.

\* Use centralized error middleware.

\* Use consistent API response format.

\* Use async handler to reduce try/catch repetition.

\* Use environment variables for secrets.

\* Do not commit `.env`.

\* Provide `.env.example`.

\* All protected routes must use Firebase auth middleware.



\## 8. Mobile Requirements



\### 8.1 Mobile Folder Structure



```txt

mobile/

\&#x20; lib/

\&#x20;   main.dart

\&#x20;   app/

\&#x20;     app.dart

\&#x20;     router/

\&#x20;       app\\\_router.dart

\&#x20;     theme/

\&#x20;       app\\\_theme.dart

\&#x20;     constants/

\&#x20;       app\\\_colors.dart

\&#x20;       app\\\_spacing.dart

\&#x20;       app\\\_strings.dart

\&#x20;   core/

\&#x20;     network/

\&#x20;       dio\\\_client.dart

\&#x20;       auth\\\_interceptor.dart

\&#x20;       api\\\_exception.dart

\&#x20;     storage/

\&#x20;       local\\\_storage.dart

\&#x20;     utils/

\&#x20;       currency\\\_formatter.dart

\&#x20;       date\\\_formatter.dart

\&#x20;       validators.dart

\&#x20;     widgets/

\&#x20;       app\\\_button.dart

\&#x20;       app\\\_text\\\_field.dart

\&#x20;       loading\\\_view.dart

\&#x20;       empty\\\_state.dart

\&#x20;       error\\\_view.dart

\&#x20;   features/

\&#x20;     auth/

\&#x20;       data/

\&#x20;       domain/

\&#x20;       presentation/

\&#x20;     dashboard/

\&#x20;       data/

\&#x20;       domain/

\&#x20;       presentation/

\&#x20;     wallets/

\&#x20;       data/

\&#x20;       domain/

\&#x20;       presentation/

\&#x20;     categories/

\&#x20;       data/

\&#x20;       domain/

\&#x20;       presentation/

\&#x20;     transactions/

\&#x20;       data/

\&#x20;       domain/

\&#x20;       presentation/

\&#x20;     budgets/

\&#x20;       data/

\&#x20;       domain/

\&#x20;       presentation/

\&#x20;     activity/

\&#x20;       data/

\&#x20;       domain/

\&#x20;       presentation/

\&#x20;     profile/

\&#x20;       data/

\&#x20;       domain/

\&#x20;       presentation/

```



\### 8.2 Mobile Architecture Rules



\* Use feature-based clean architecture.

\* Do not put API calls directly inside widgets.

\* Use repositories for data access.

\* Use Riverpod providers/controllers for state management.

\* Use Dio for REST API.

\* Use go\_router for navigation.

\* Use Firebase Auth for auth state.

\* Use Firestore stream only for activity feed and finance tips.

\* Business logic should not live inside UI widgets.

\* UI must handle loading, empty, and error states.



\## 9. API Response Format



\### Success Response



```json

{

\&#x20; "success": true,

\&#x20; "message": "Success message",

\&#x20; "data": {}

}

```



\### Error Response



```json

{

\&#x20; "success": false,

\&#x20; "message": "Error message",

\&#x20; "errors": \\\[]

}

```



\## 10. PostgreSQL Database Design



\### 10.1 User



Fields:



\* id: UUID

\* firebaseUid: string unique

\* email: string unique

\* name: string nullable

\* photoUrl: string nullable

\* createdAt: DateTime

\* updatedAt: DateTime



Relations:



\* User has many Wallets.

\* User has many Categories.

\* User has many Transactions.

\* User has many Budgets.



\### 10.2 Wallet



Fields:



\* id: UUID

\* userId: UUID

\* name: string

\* type: string

\* initialBalance: Decimal

\* currentBalance: Decimal

\* currency: string default IDR

\* isArchived: boolean default false

\* createdAt: DateTime

\* updatedAt: DateTime



Relations:



\* Wallet belongs to User.

\* Wallet has many Transactions.



\### 10.3 Category



Fields:



\* id: UUID

\* userId: UUID

\* name: string

\* type: enum INCOME or EXPENSE

\* icon: string nullable

\* color: string nullable

\* isDefault: boolean default false

\* createdAt: DateTime

\* updatedAt: DateTime



Relations:



\* Category belongs to User.

\* Category has many Transactions.

\* Category has many Budgets.



\### 10.4 Transaction



Fields:



\* id: UUID

\* userId: UUID

\* walletId: UUID

\* categoryId: UUID

\* type: enum INCOME or EXPENSE

\* amount: Decimal

\* title: string

\* note: string nullable

\* transactionDate: DateTime

\* createdAt: DateTime

\* updatedAt: DateTime



Relations:



\* Transaction belongs to User.

\* Transaction belongs to Wallet.

\* Transaction belongs to Category.



\### 10.5 Budget



Fields:



\* id: UUID

\* userId: UUID

\* categoryId: UUID

\* month: int

\* year: int

\* limitAmount: Decimal

\* createdAt: DateTime

\* updatedAt: DateTime



Relations:



\* Budget belongs to User.

\* Budget belongs to Category.



Constraint:



\* Unique userId + categoryId + month + year.



\## 11. Prisma Schema Draft



```prisma

generator client {

\&#x20; provider = "prisma-client-js"

}



datasource db {

\&#x20; provider = "postgresql"

\&#x20; url      = env("DATABASE\\\_URL")

}



enum TransactionType {

\&#x20; INCOME

\&#x20; EXPENSE

}



model User {

\&#x20; id          String        @id @default(uuid())

\&#x20; firebaseUid String       @unique

\&#x20; email       String       @unique

\&#x20; name        String?

\&#x20; photoUrl    String?

\&#x20; wallets     Wallet\\\[]

\&#x20; categories  Category\\\[]

\&#x20; transactions Transaction\\\[]

\&#x20; budgets     Budget\\\[]

\&#x20; createdAt   DateTime     @default(now())

\&#x20; updatedAt   DateTime     @updatedAt

}



model Wallet {

\&#x20; id             String        @id @default(uuid())

\&#x20; userId         String

\&#x20; user           User          @relation(fields: \\\[userId], references: \\\[id], onDelete: Cascade)

\&#x20; name           String

\&#x20; type           String

\&#x20; initialBalance Decimal       @db.Decimal(14, 2)

\&#x20; currentBalance Decimal       @db.Decimal(14, 2)

\&#x20; currency       String        @default("IDR")

\&#x20; isArchived     Boolean       @default(false)

\&#x20; transactions   Transaction\\\[]

\&#x20; createdAt      DateTime      @default(now())

\&#x20; updatedAt      DateTime      @updatedAt



\&#x20; @@index(\\\[userId])

}



model Category {

\&#x20; id           String          @id @default(uuid())

\&#x20; userId       String

\&#x20; user         User            @relation(fields: \\\[userId], references: \\\[id], onDelete: Cascade)

\&#x20; name         String

\&#x20; type         TransactionType

\&#x20; icon         String?

\&#x20; color        String?

\&#x20; isDefault    Boolean         @default(false)

\&#x20; transactions Transaction\\\[]

\&#x20; budgets      Budget\\\[]

\&#x20; createdAt    DateTime        @default(now())

\&#x20; updatedAt    DateTime        @updatedAt



\&#x20; @@index(\\\[userId])

\&#x20; @@index(\\\[type])

}



model Transaction {

\&#x20; id              String          @id @default(uuid())

\&#x20; userId          String

\&#x20; user            User            @relation(fields: \\\[userId], references: \\\[id], onDelete: Cascade)

\&#x20; walletId        String

\&#x20; wallet          Wallet          @relation(fields: \\\[walletId], references: \\\[id])

\&#x20; categoryId      String

\&#x20; category        Category        @relation(fields: \\\[categoryId], references: \\\[id])

\&#x20; type            TransactionType

\&#x20; amount          Decimal         @db.Decimal(14, 2)

\&#x20; title           String

\&#x20; note            String?

\&#x20; transactionDate DateTime

\&#x20; createdAt       DateTime        @default(now())

\&#x20; updatedAt       DateTime        @updatedAt



\&#x20; @@index(\\\[userId])

\&#x20; @@index(\\\[walletId])

\&#x20; @@index(\\\[categoryId])

\&#x20; @@index(\\\[transactionDate])

\&#x20; @@index(\\\[type])

}



model Budget {

\&#x20; id          String   @id @default(uuid())

\&#x20; userId      String

\&#x20; user        User     @relation(fields: \\\[userId], references: \\\[id], onDelete: Cascade)

\&#x20; categoryId  String

\&#x20; category    Category @relation(fields: \\\[categoryId], references: \\\[id])

\&#x20; month       Int

\&#x20; year        Int

\&#x20; limitAmount Decimal  @db.Decimal(14, 2)

\&#x20; createdAt   DateTime @default(now())

\&#x20; updatedAt   DateTime @updatedAt



\&#x20; @@unique(\\\[userId, categoryId, month, year])

\&#x20; @@index(\\\[userId])

}

```



\## 12. Firestore Design



\### 12.1 Activity Feed Collection



Path:



```txt

users/{firebaseUid}/activity\\\_feed/{activityId}

```



Example document:



```json

{

\&#x20; "type": "transaction\\\_created",

\&#x20; "title": "Added expense",

\&#x20; "message": "Food - Rp50.000",

\&#x20; "amount": 50000,

\&#x20; "transactionType": "EXPENSE",

\&#x20; "categoryName": "Food",

\&#x20; "walletName": "Cash",

\&#x20; "createdAt": "serverTimestamp"

}

```



Allowed activity types:



\* transaction\_created

\* transaction\_updated

\* transaction\_deleted

\* budget\_created

\* budget\_updated

\* wallet\_created



Rules:



\* Store summary only.

\* Do not store sensitive full transaction detail.

\* UI should show latest 20 activity items.



\### 12.2 Finance Tips Collection



Path:



```txt

finance\\\_tips/{tipId}

```



Example document:



```json

{

\&#x20; "title": "Track small expenses",

\&#x20; "content": "Small daily expenses can become large monthly spending.",

\&#x20; "isActive": true,

\&#x20; "createdAt": "serverTimestamp"

}

```



\## 13. Firestore Security Rules Concept



```txt

users/{userId}/activity\\\_feed/{activityId}

\\- allow read, write if request.auth.uid == userId



users/{userId}/notifications/{notificationId}

\\- allow read, write if request.auth.uid == userId



finance\\\_tips/{tipId}

\\- allow read if request.auth != null

\\- allow write if false

```



\## 14. Wallet Balance Logic



\### Create Income



```txt

wallet.currentBalance += amount

```



\### Create Expense



```txt

wallet.currentBalance -= amount

```



\### Delete Income



```txt

wallet.currentBalance -= amount

```



\### Delete Expense



```txt

wallet.currentBalance += amount

```



\### Update Transaction



1\. Reverse old transaction effect.

2\. Apply new transaction effect.

3\. If wallet changes, reverse effect from old wallet and apply effect to new wallet.

4\. Use database transaction to keep data consistent.



Use Prisma transaction for:



\* create transaction + update wallet

\* update transaction + update wallet

\* delete transaction + update wallet



\## 15. Dashboard Calculation



\### Total Balance



```txt

sum(currentBalance of all active wallets)

```



\### Monthly Income



```txt

sum(amount) where type = INCOME and transactionDate is in selected month/year

```



\### Monthly Expense



```txt

sum(amount) where type = EXPENSE and transactionDate is in selected month/year

```



\### Net Cash Flow



```txt

monthlyIncome - monthlyExpense

```



\### Budget Used Amount



```txt

sum(expense transaction amount)

where categoryId = budget.categoryId

and transactionDate is in selected month/year

```



\### Budget Remaining



```txt

limitAmount - usedAmount

```



\### Budget Usage Percentage



```txt

(usedAmount / limitAmount) \\\* 100

```



\## 16. Security Requirements



\* Backend verifies Firebase ID token on protected routes.

\* Backend does not trust userId from client.

\* All database queries are scoped by authenticated user.

\* Use Zod validation.

\* Use environment variables.

\* Do not commit secrets.

\* Firestore rules prevent cross-user access.

\* Return safe error messages.

\* Use CORS configuration.

\* Use centralized error handler.



\## 17. Environment Variables



Backend `.env.example` should include:



```env

NODE\\\_ENV=development

PORT=3000

DATABASE\\\_URL="postgresql://fintrack:fintrack\\\_password@localhost:5433/fintrack\\\_db?schema=public"



FIREBASE\\\_PROJECT\\\_ID=""

FIREBASE\\\_CLIENT\\\_EMAIL=""

FIREBASE\\\_PRIVATE\\\_KEY=""

```



\## 18. Local Development Requirements



Backend should run with:



```bash

npm install

npm run dev

```



Prisma commands:



```bash

npx prisma format

npx prisma migrate dev --name init

npx prisma generate

npx prisma studio

```



Mobile should run with:



```bash

flutter pub get

flutter analyze

flutter run

```



Docker PostgreSQL should run with:



```bash

docker compose up -d

```



\## 19. Testing Requirements



Backend testing-ready structure:



\* auth middleware test

\* wallet service test

\* transaction balance logic test

\* budget calculation test

\* dashboard summary test



Mobile testing-ready structure:



\* login form validation test

\* currency formatter test

\* transaction form validation test

\* controller/provider test if practical



\## 20. Code Quality Requirements



\* Clear naming.

\* Small functions.

\* Consistent response format.

\* Centralized error handling.

\* Avoid duplicate logic.

\* Keep business logic out of UI.

\* Keep financial calculation on backend.

\* Avoid unnecessary dependencies.

\* Use formatter and analyzer.

\* Update README when setup changes.




