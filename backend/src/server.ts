import { app } from "./app";
import { assertRequiredEnv, env } from "./config/env";
import { prisma } from "./config/prisma";

assertRequiredEnv();

const server = app.listen(env.port, env.host, () => {
  console.log(`FinTrack API running on ${env.host}:${env.port}`);
});

let shuttingDown = false;

// Stop accepting connections, let in-flight requests finish, then release the
// database pool. Hosting platforms send SIGTERM on every deploy.
const shutdown = (signal: string) => {
  if (shuttingDown) return;
  shuttingDown = true;

  console.log(`${signal} received, shutting down`);

  const forceExit = setTimeout(() => process.exit(1), 10_000);
  forceExit.unref();

  server.close(async () => {
    await prisma.$disconnect();
    process.exit(0);
  });
};

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));

process.on("unhandledRejection", (reason) => {
  console.error("Unhandled promise rejection", reason);
});
