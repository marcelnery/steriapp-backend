import express from "express";

import { authMiddleware } from "../middleware/auth.middleware.js";
import { saveLaudo } from "../controllers/laudo.controller.js";


const router = express.Router();

router.post("/laudo", authMiddleware, saveLaudo);

export default router;      