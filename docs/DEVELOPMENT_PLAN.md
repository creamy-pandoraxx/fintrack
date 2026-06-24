\# Development Plan — FinTrack



## 1. Development Strategy



FinTrack must be built incrementally. Do not generate the full application in one step.



The safest strategy:



1\\\\\\\\. Setup foundation.

2\\\\\\\\. Build backend first.

3\\\\\\\\. Stabilize database and API logic.

4\\\\\\\\. Add Firebase authentication.

5\\\\\\\\. Add Firestore activity feed.

6\\\\\\\\. Build Flutter app after backend API is stable.

7\\\\\\\\. Polish UI.

8\\\\\\\\. Add documentation and portfolio material.



\\\\\\\\## 2. Important Development Rules



\\\\\\\\- Work in small milestones.

\\\\\\\\- Commit after every stable milestone.

\\\\\\\\- Do not mix too many features in one commit.

\\\\\\\\- Do not implement nice-to-have features before MVP is stable.

\\\\\\\\- Prioritize correctness over speed.

\\\\\\\\- Keep PostgreSQL as financial source of truth.

\\\\\\\\- Keep Firestore only for realtime/semi-structured data.

\\\\\\\\- Never trust userId from frontend.

\\\\\\\\- Always run available checks before committing.

\\\\\\\\- Keep README updated.



\\\\\\\\## 3. Recommended Git Commit Pattern



Use small and clear commit messages:



```txt

chore: initialize project structure

chore: setup backend foundation

feat: add Prisma schema

feat: add Firebase auth middleware

feat: add user sync endpoint

feat: add wallet CRUD API

feat: add category CRUD API

feat: add transaction CRUD API

feat: add budget API

feat: add dashboard summary API

feat: add Firestore activity feed

chore: setup Flutter foundation

feat: add Flutter auth flow

feat: add dashboard screen

feat: add wallet screens

feat: add transaction screens

feat: add budget screens

docs: update README

````



\## 4. Milestone 0 — Repository Setup



\### Goal



Create clean repository structure.



\### Target Structure



```txt

fintrack/

\\\\\\\&#x20; backend/

\\\\\\\&#x20; mobile/

\\\\\\\&#x20; docs/

\\\\\\\&#x20; .codex/

\\\\\\\&#x20; AGENTS.md

\\\\\\\&#x20; README.md

\\\\\\\&#x20; docker-compose.yml

```



\### Tasks



\* Initialize Git repository.

\* Create root README.

\* Create docs files.

\* Create AGENTS.md.

\* Create docker-compose.yml for PostgreSQL.

\* Prepare project instructions for Codex.



\### Acceptance Criteria



\* Repository is initialized.

\* Folder structure exists.

\* Documentation files exist.

\* PostgreSQL can run with Docker.

\* Codex can read AGENTS.md and docs.



\## 5. Milestone 1 — Backend Foundation



\### Goal



Create backend TypeScript Express foundation.



\### Tasks



\* Initialize Node.js project in backend.

\* Install dependencies.

\* Setup TypeScript.

\* Create Express app.

\* Create server entrypoint.

\* Create health check endpoint.

\* Setup environment config.

\* Setup centralized error middleware.

\* Setup API response utility.

\* Setup async handler utility.

\* Setup Prisma client singleton placeholder.

\* Add `.env.example`.



\### Suggested Dependencies



Runtime:



```txt

express

cors

dotenv

@prisma/client

zod

firebase-admin

```



Development:



```txt

typescript

tsx

prisma

@types/node

@types/express

```



\### Acceptance Criteria



\* Backend can run locally.

\* Health endpoint returns success.

\* TypeScript compiles.

\* Folder structure is clean.

\* `.env.example` exists.



\### Verification Commands



```bash

cd backend

npm install

npm run dev

```



Health check:



```bash

curl http://localhost:3000/health

```



\## 6. Milestone 2 — Prisma Schema and Database



\### Goal



Create PostgreSQL schema for financial source of truth.



\### Tasks



\* Setup Prisma.

\* Create database models:



&#x20; \* User

&#x20; \* Wallet

&#x20; \* Category

&#x20; \* Transaction

&#x20; \* Budget

\* Add enum TransactionType.

\* Add relations.

\* Add indexes.

\* Add unique constraint for budget.

\* Add Decimal fields for money.

\* Run Prisma migration.

\* Generate Prisma client.



\### Acceptance Criteria



\* Prisma schema is valid.

\* Migration runs successfully.

\* PostgreSQL has required tables.

\* Prisma client is generated.

\* Prisma Studio can open.



\### Verification Commands



```bash

cd backend

npx prisma format

npx prisma migrate dev --name init

npx prisma generate

npx prisma studio

```



\## 7. Milestone 3 — Firebase Admin Auth Middleware



\### Goal



Secure backend with Firebase ID Token verification.



\### Tasks



\* Setup Firebase Admin SDK.

\* Read Firebase credentials from environment variables.

\* Create auth middleware.

\* Verify Authorization Bearer token.

\* Attach authenticated user context to request.

\* Return 401 for missing or invalid token.

\* Add TypeScript request typing if needed.



\### Acceptance Criteria



\* Protected routes reject missing token.

\* Protected routes reject invalid token.

\* Protected routes accept valid Firebase ID Token.

\* Backend can access firebaseUid and email from token.

\* Backend never trusts userId from request body.



\## 8. Milestone 4 — User Sync and Default Categories



\### Goal



Create user profile in PostgreSQL after Firebase authentication.



\### Endpoints



```txt

POST /api/v1/auth/sync

GET /api/v1/users/me

PATCH /api/v1/users/me

```



\### Tasks



\* Implement auth sync.

\* Create user if not exists.

\* Return existing user if already exists.

\* Generate default categories for new user.

\* Implement get current user endpoint.

\* Implement update profile endpoint.

\* Add validation.



\### Acceptance Criteria



\* New Firebase user can sync to PostgreSQL.

\* Existing user is not duplicated.

\* New user receives default categories.

\* Profile can be retrieved.

\* Profile can be updated.



\## 9. Milestone 5 — Wallet API



\### Goal



Allow users to manage wallets.



\### Endpoints



```txt

GET /api/v1/wallets

POST /api/v1/wallets

GET /api/v1/wallets/:id

PATCH /api/v1/wallets/:id

DELETE /api/v1/wallets/:id

```



\### Tasks



\* Implement wallet routes.

\* Implement wallet service.

\* Implement Zod validation.

\* Implement soft delete using isArchived.

\* Scope all queries to authenticated user.



\### Acceptance Criteria



\* User can create wallet.

\* User can list active wallets.

\* User can view wallet detail.

\* User can update wallet.

\* User can archive wallet.

\* User cannot access another user’s wallet.

\* currentBalance equals initialBalance on create.



\## 10. Milestone 6 — Category API



\### Goal



Allow users to manage categories.



\### Endpoints



```txt

GET /api/v1/categories

POST /api/v1/categories

PATCH /api/v1/categories/:id

DELETE /api/v1/categories/:id

```



\### Tasks



\* Implement category routes.

\* Support query param type.

\* Add category validation.

\* Prevent deleting category with transactions.

\* Scope all queries to authenticated user.



\### Acceptance Criteria



\* User can list categories.

\* User can filter by INCOME or EXPENSE.

\* User can create custom category.

\* User can update category.

\* User cannot delete category with transactions.

\* User cannot access another user’s category.



\## 11. Milestone 7 — Transaction API



\### Goal



Implement core financial transaction logic.



\### Endpoints



```txt

GET /api/v1/transactions

POST /api/v1/transactions

GET /api/v1/transactions/:id

PATCH /api/v1/transactions/:id

DELETE /api/v1/transactions/:id

```



\### Tasks



\* Implement transaction CRUD.

\* Add pagination.

\* Add filters.

\* Validate wallet ownership.

\* Validate category ownership.

\* Validate category type matches transaction type.

\* Implement wallet balance adjustment.

\* Use Prisma transaction for create/update/delete.

\* Scope all queries to authenticated user.



\### Acceptance Criteria



\* User can create income.

\* User can create expense.

\* Income increases wallet balance.

\* Expense decreases wallet balance.

\* Delete reverses wallet balance.

\* Update reverses old effect and applies new effect.

\* Transaction list supports filters.

\* User cannot access another user’s transaction.



\## 12. Milestone 8 — Budget API



\### Goal



Allow users to manage monthly budgets.



\### Endpoints



```txt

GET /api/v1/budgets

POST /api/v1/budgets

PATCH /api/v1/budgets/:id

DELETE /api/v1/budgets/:id

```



\### Tasks



\* Implement budget CRUD.

\* Validate month, year, category, and amount.

\* Ensure category is EXPENSE.

\* Prevent duplicate budget for same category/month/year.

\* Calculate used amount.

\* Calculate remaining amount.

\* Calculate usage percentage.



\### Acceptance Criteria



\* User can create budget.

\* User can list budget by month/year.

\* User can update budget.

\* User can delete budget.

\* Duplicate budget is rejected.

\* Budget usage is calculated from expense transactions.



\## 13. Milestone 9 — Dashboard API



\### Goal



Provide summary data for mobile dashboard.



\### Endpoint



```txt

GET /api/v1/dashboard/summary

```



\### Tasks



\* Calculate total balance.

\* Calculate monthly income.

\* Calculate monthly expense.

\* Calculate net cash flow.

\* Calculate expense by category.

\* Return budget summary.

\* Return recent transactions.



\### Acceptance Criteria



\* Dashboard returns accurate financial summary.

\* Dashboard is scoped to authenticated user.

\* Dashboard handles empty data gracefully.

\* Dashboard returns recent transactions.



\## 14. Milestone 10 — Firestore Activity Feed



\### Goal



Add meaningful NoSQL usage.



\### Tasks



\* Create Firestore service.

\* Create activity event after transaction create.

\* Create activity event after transaction update.

\* Create activity event after transaction delete.

\* Store activity in users/{firebaseUid}/activity\_feed.

\* Store summary only.

\* Do not store full transaction as source of truth.



\### Acceptance Criteria



\* Activity feed document is created after transaction changes.

\* Activity feed path uses Firebase UID.

\* Activity feed contains readable summary.

\* Firestore is not used as primary financial database.



\## 15. Milestone 11 — Flutter Foundation



\### Goal



Initialize Flutter app with clean structure.



\### Tasks



\* Create Flutter project inside mobile.

\* Add dependencies:



&#x20; \* flutter\_riverpod

&#x20; \* dio

&#x20; \* go\_router

&#x20; \* firebase\_core

&#x20; \* firebase\_auth

&#x20; \* cloud\_firestore

&#x20; \* fl\_chart

&#x20; \* shared\_preferences

\* Setup app theme.

\* Setup router.

\* Setup Dio client.

\* Setup auth interceptor placeholder.

\* Create reusable widgets:



&#x20; \* AppButton

&#x20; \* AppTextField

&#x20; \* LoadingView

&#x20; \* EmptyState

&#x20; \* ErrorView



\### Acceptance Criteria



\* Flutter app runs.

\* Flutter analyze passes.

\* App has clean folder structure.

\* Navigation foundation exists.

\* Theme foundation exists.



\### Verification Commands



```bash

cd mobile

flutter pub get

flutter analyze

flutter run

```



\## 16. Milestone 12 — Flutter Authentication Flow



\### Goal



Implement mobile auth screens and Firebase Auth.



\### Screens



\* Splash screen

\* Welcome screen

\* Login screen

\* Register screen



\### Tasks



\* Setup Firebase in Flutter.

\* Implement register.

\* Implement login.

\* Implement logout.

\* Implement auth state redirect.

\* Get Firebase ID Token.

\* Call backend `/auth/sync`.

\* Store lightweight session info if needed.



\### Acceptance Criteria



\* User can register.

\* User can login.

\* User can logout.

\* Auth state persists.

\* Backend receives valid token.

\* App redirects correctly.



\## 17. Milestone 13 — Flutter Dashboard



\### Goal



Implement dashboard UI.



\### Tasks



\* Fetch `/dashboard/summary`.

\* Display total balance.

\* Display monthly income.

\* Display monthly expense.

\* Display net cash flow.

\* Display expense chart.

\* Display budget progress.

\* Display recent transactions.

\* Display finance tip from Firestore.

\* Display activity feed preview from Firestore.



\### Acceptance Criteria



\* Dashboard loads data.

\* Loading state appears.

\* Error state appears if API fails.

\* Empty state works.

\* Currency is formatted as IDR.

\* Chart displays expense breakdown.



\## 18. Milestone 14 — Flutter Wallet Feature



\### Goal



Implement wallet management UI.



\### Screens



\* Wallet list screen

\* Add wallet screen

\* Edit wallet screen



\### Tasks



\* Create wallet repository.

\* Create wallet controller/provider.

\* Connect to wallet API.

\* Implement create wallet.

\* Implement update wallet.

\* Implement archive wallet.

\* Refresh list after mutation.



\### Acceptance Criteria



\* User can see wallets.

\* User can create wallet.

\* User can edit wallet.

\* User can archive wallet.

\* UI handles loading, error, and empty state.



\## 19. Milestone 15 — Flutter Category Feature



\### Goal



Implement category management UI.



\### Screens



\* Category list screen

\* Add category screen

\* Edit category screen



\### Tasks



\* Create category repository.

\* Create category controller/provider.

\* Connect to category API.

\* Add income/expense tabs.

\* Add create/update/delete actions.



\### Acceptance Criteria



\* User can see income categories.

\* User can see expense categories.

\* User can create custom category.

\* User can edit category.

\* User can delete category if allowed.



\## 20. Milestone 16 — Flutter Transaction Feature



\### Goal



Implement transaction UI.



\### Screens



\* Transaction list screen

\* Add transaction screen

\* Edit transaction screen

\* Transaction detail screen optional



\### Tasks



\* Create transaction repository.

\* Create transaction controller/provider.

\* Add transaction form validation.

\* Load wallet and category options.

\* Filter categories based on selected type.

\* Create transaction.

\* Update transaction.

\* Delete transaction.

\* Add transaction filters.



\### Acceptance Criteria



\* User can create income.

\* User can create expense.

\* User can edit transaction.

\* User can delete transaction.

\* Wallet balance updates after refresh.

\* Form prevents invalid input.

\* List supports basic filter/search.



\## 21. Milestone 17 — Flutter Budget Feature



\### Goal



Implement budget management UI.



\### Screens



\* Budget list screen

\* Add budget screen

\* Edit budget screen



\### Tasks



\* Create budget repository.

\* Create budget controller/provider.

\* Load expense categories.

\* Create budget.

\* Update budget.

\* Delete budget.

\* Show progress bar.



\### Acceptance Criteria



\* User can create monthly budget.

\* User can update budget.

\* User can delete budget.

\* Budget progress is visible.

\* Duplicate budget error is handled.



\## 22. Milestone 18 — UI Polish



\### Goal



Make the app portfolio-ready.



\### Tasks



\* Improve spacing.

\* Improve typography.

\* Improve colors.

\* Improve empty states.

\* Improve loading states.

\* Improve error messages.

\* Add consistent card styles.

\* Add currency and date formatting.

\* Check navigation consistency.

\* Check responsiveness on different Android screen sizes.



\### Acceptance Criteria



\* App looks clean and modern.

\* Main flows are smooth.

\* Error states are understandable.

\* UI is consistent.

\* App is ready for screenshots.



\## 23. Milestone 19 — Documentation and Portfolio



\### Goal



Prepare project for portfolio and recruiter review.



\### Tasks



\* Update root README.

\* Add backend README.

\* Add mobile README.

\* Add setup instructions.

\* Add environment variable explanation.

\* Add screenshots.

\* Add architecture explanation.

\* Add SQL vs NoSQL explanation.

\* Add API endpoint summary.

\* Add future improvements.

\* Add portfolio case study.



\### README Must Include



\* Project overview.

\* Tech stack.

\* Features.

\* Architecture.

\* Database design.

\* API documentation.

\* Setup backend.

\* Setup mobile.

\* Firebase setup.

\* Docker setup.

\* Screenshots.

\* Future improvements.



\## 24. Codex Prompt Workflow



Use this workflow when asking Codex to work:



```txt

Read AGENTS.md and relevant docs first.



Before editing files:

1\\\\\\\\. Inspect relevant files.

2\\\\\\\\. Explain your plan.

3\\\\\\\\. List files you will modify.

4\\\\\\\\. Implement only the requested feature.

5\\\\\\\\. Run available checks.

6\\\\\\\\. Summarize changes and remaining risks.

```



\## 25. First Codex Prompt



Use this as the first development prompt:



```txt

Read AGENTS.md and all files inside docs/.



Do not implement the full app yet.



First, inspect the current repository and create the initial foundation only:

\\\\\\\\- backend folder structure for Node.js Express TypeScript

\\\\\\\\- mobile folder structure placeholder for Flutter

\\\\\\\\- docs folder preservation

\\\\\\\\- .env.example for backend

\\\\\\\\- base README draft

\\\\\\\\- package.json for backend

\\\\\\\\- tsconfig.json

\\\\\\\\- basic Express app entrypoint

\\\\\\\\- health check endpoint

\\\\\\\\- Prisma setup placeholder

\\\\\\\\- Docker/PostgreSQL usage note



Important:

\\\\\\\\- Work incrementally.

\\\\\\\\- Before editing files, summarize your plan.

\\\\\\\\- Do not add unnecessary dependencies.

\\\\\\\\- Do not implement wallet, transaction, budget, or Firebase yet.

\\\\\\\\- After creating files, tell me exactly what commands I should run to verify.

```



\## 26. Risk Management



\### Risk 1 — Codex overbuilds



Solution:



Ask Codex to implement only one milestone at a time.



\### Risk 2 — Backend logic becomes inconsistent



Solution:



Keep transaction and wallet balance logic in backend service with Prisma transaction.



\### Risk 3 — Firestore becomes source of truth accidentally



Solution:



AGENTS.md and docs must clearly state PostgreSQL is the source of truth.



\### Risk 4 — Flutter widgets become too messy



Solution:



Use repositories, controllers/providers, and feature-based structure.



\### Risk 5 — Scope becomes too large



Solution:



Do not implement nice-to-have features until MVP is done.



\## 27. MVP Completion Checklist



Backend:



\* \[ ] Express TypeScript app works.

\* \[ ] PostgreSQL runs with Docker.

\* \[ ] Prisma schema exists.

\* \[ ] Firebase auth middleware works.

\* \[ ] User sync works.

\* \[ ] Wallet CRUD works.

\* \[ ] Category CRUD works.

\* \[ ] Transaction CRUD works.

\* \[ ] Wallet balance logic works.

\* \[ ] Budget CRUD works.

\* \[ ] Dashboard summary works.

\* \[ ] Firestore activity feed works.



Mobile:



\* \[ ] Flutter app runs.

\* \[ ] Firebase Auth works.

\* \[ ] Login works.

\* \[ ] Register works.

\* \[ ] Dashboard screen works.

\* \[ ] Wallet screens work.

\* \[ ] Category screens work.

\* \[ ] Transaction screens work.

\* \[ ] Budget screens work.

\* \[ ] Activity feed appears.

\* \[ ] UI is polished.



Documentation:



\* \[ ] README complete.

\* \[ ] Setup guide complete.

\* \[ ] API documentation complete.

\* \[ ] Screenshots added.

\* \[ ] Portfolio explanation added.



```

```



