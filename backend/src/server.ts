import { app } from "./app";
import { env } from "./config/env";

app.listen(env.port, env.host, () => {
  console.log(`FinTrack API running on ${env.host}:${env.port}`);
});
