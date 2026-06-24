import { Router } from "express";

import { healthRouter } from "../modules/health/health.routes";
import { authRouter } from "../modules/auth/auth.routes";
import { categoryRouter } from "../modules/categories/category.routes";
import { userRouter } from "../modules/users/user.routes";
import { walletRouter } from "../modules/wallets/wallet.routes";

const router = Router();
const apiRouter = Router();

router.use(healthRouter);
apiRouter.use(authRouter);
apiRouter.use(userRouter);
apiRouter.use(walletRouter);
apiRouter.use(categoryRouter);

router.use("/api/v1", apiRouter);

export default router;
