# FinTrack Documentation

This directory contains the product, technical, API, delivery, and QA records for the FinTrack portfolio project.

## Document Map

| Document | Purpose |
| --- | --- |
| [PRD.md](PRD.md) | Product goals, MVP scope, user flows, and future ideas |
| [TECHNICAL_REQUIRMENTS.md](TECHNICAL_REQUIRMENTS.md) | Architecture, data ownership, security, and platform requirements |
| [API_SPEC.MD](API_SPEC.MD) | REST endpoint request/response contract |
| [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) | Incremental implementation stages |
| [MVP_QA_CHECKLIST.md](MVP_QA_CHECKLIST.md) | Automated and manual readiness checks |
| [screenshots/README.md](screenshots/README.md) | Portfolio screenshot capture and redaction checklist |

## Current Status

FinTrack is a functional Android-focused MVP. Authentication, user synchronization, wallets, categories, transactions, budgets, dashboard reporting, activity feed, finance tips, profile actions, and account deletion are implemented.

The following remain outside the current release:

- production hosting and HTTPS infrastructure;
- CI/CD and release distribution;
- generated OpenAPI/Swagger UI;
- comprehensive backend integration tests;
- offline-first behavior, push notifications, and recurring transactions;
- final screenshots and broader physical-device QA.

## Non-Negotiable Data Boundary

PostgreSQL is the source of truth for users and all financial data. Firestore is limited to realtime activity summaries and finance tips. Flutter sends financial mutations to the Express REST API and never writes primary financial records to Firestore.

## Setup Entry Points

- Full project setup: [../README.md](../README.md)
- Backend setup: [../backend/README.md](../backend/README.md)
- Android/Flutter setup: [../mobile/README.md](../mobile/README.md)

When implementation and an older planning statement differ, verify behavior against the current source code and update the relevant document before presenting the project.
