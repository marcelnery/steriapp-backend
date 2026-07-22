import express from "express";
import { openLabel } from "../controllers/label.controller.js";

const router = express.Router();

router.get("/label/:serial/:cycle", openLabel);

export default router;