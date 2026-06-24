\# AGENTS.md — FinTrack Project Instructions



\## Project Overview

FinTrack is a full-stack mobile portfolio project for personal finance tracking.



The project has three main parts:

\- mobile: Flutter mobile app

\- backend: Node.js Express TypeScript REST API

\- docs: product and technical documentation



\## Main Goal

Build a portfolio-grade full-stack mobile app that demonstrates:

\- Flutter mobile development

\- RESTful API integration

\- PostgreSQL relational database design

\- Firebase Authentication

\- Firestore NoSQL usage

\- Clean architecture

\- Riverpod state management

\- Prisma ORM

\- Backend validation and error handling



\## Tech Stack

Mobile:

\- Flutter

\- Dart

\- Riverpod

\- Dio

\- go\_router

\- Firebase Auth

\- Cloud Firestore

\- fl\_chart



Backend:

\- Node.js

\- TypeScript

\- Express.js

\- Prisma

\- PostgreSQL

\- Firebase Admin SDK

\- Zod

\- Swagger/OpenAPI



Database:

\- PostgreSQL is the source of truth for financial data.

\- Firestore is only for activity feed, notification logs, finance tips, or remote config.



\## Strict Architecture Rules

\- Do not store primary financial transaction data in Firestore.

\- PostgreSQL must store users, wallets, categories, transactions, and budgets.

\- Backend must expose RESTful APIs.

\- Flutter must not directly write financial data to PostgreSQL.

\- Flutter must communicate with backend through REST API.

\- Backend must verify Firebase ID token using Firebase Admin SDK.

\- Never trust userId from request body.

\- All backend queries must be scoped to authenticated user.



\## Development Rules

\- Work incrementally.

\- Do not implement all features at once.

\- Before writing code, explain the intended file changes briefly.

\- After changing backend code, run TypeScript checks or tests if available.

\- After changing Flutter code, run flutter analyze if available.

\- Keep code clean and portfolio-grade.

\- Prefer feature-based folder structure.

\- Avoid unnecessary dependencies.

\- Do not commit secrets.

\- Always create .env.example when adding environment variables.



\## MVP Feature Order

1\. Project foundation

2\. Backend setup

3\. Prisma schema

4\. Firebase Admin auth middleware

5\. User sync endpoint

6\. Wallet CRUD

7\. Category CRUD

8\. Transaction CRUD with wallet balance logic

9\. Budget CRUD

10\. Dashboard summary API

11\. Firestore activity feed

12\. Flutter foundation

13\. Flutter auth flow

14\. Flutter dashboard

15\. Flutter wallet UI

16\. Flutter category UI

17\. Flutter transaction UI

18\. Flutter budget UI

19\. UI polish

20\. Documentation



\## Code Quality

\- Use clear names.

\- Use small functions.

\- Keep business logic out of UI widgets.

\- Use repositories/services.

\- Add validation.

\- Handle loading, empty, and error states.

\- Keep README updated.



\## Git Workflow

\- Make small commits after each stable milestone.

\- Do not mix backend and mobile changes unless needed.

\- Before large refactors, explain risk and plan.

