import express from "express";
import { saveLaudo } from "../controllers/laudo.controller.js";


const router = express.Router();

router.post("/laudo", saveLaudo);

export default router;