import express from "express";

import Cycle from "../models/Cycle.js";

import { authMiddleware }
from "../middleware/auth.middleware.js";

const router = express.Router();

// =====================================================
// GET LAUDOS
// =====================================================

router.get(
  "/laudos",
  authMiddleware,
  async (req, res) => {

    try {

      const page =
        Number(req.query.page) || 1;

      const limit =
        Number(req.query.limit) || 10;

      const skip =
        (page - 1) * limit;

      // =========================================
      // BUSCAR CICLOS DO USUÁRIO
      // =========================================

      const cycles =
        await Cycle.find({
          userId: req.userId
        })
        .sort({
          createdAt: -1
        })
        .skip(skip)
        .limit(limit);

      // =========================================
      // TOTAL
      // =========================================

      const total =
        await Cycle.countDocuments({
          userId: req.userId
        });

      // =========================================
      // RESPONSE
      // =========================================

      res.json({

        data: cycles,

        total,

        page,

        limit

      });

    }
    catch(error){

      console.error(error);

      res.status(500).json({
        error:
          "Erro ao buscar laudos"
      });
    }
  }
);

export default router;