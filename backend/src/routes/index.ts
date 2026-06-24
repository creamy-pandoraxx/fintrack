import { Router } from "express";

import { healthRouter } from "../modules/health/health.routes";
import { authRouter } from "../modules/auth/auth.routes";
import { userRouter } from "../modules/users/user.routes";

const router = Router();
const apiRouter = Router();

router.use(healthRouter);
apiRouter.use(authRouter);
apiRouter.use(userRouter);

router.use("/api/v1", apiRouter);

export default router;
