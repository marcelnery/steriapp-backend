import express from "express";
import User from "../models/user.js";

const router = express.Router();

router.post("/register", async (req, res) => {

  try {

    const {
      email,
      password,
      clinic,
      autoclaves
    } = req.body;

    // =========================
    // VERIFICAR SE USUÁRIO EXISTE
    // =========================

    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res.status(400).json({
        error: "User already exists"
      });
    }

    // =========================
    // CRIAR USUÁRIO
    // =========================

    const user = new User({
      email,
      password,
      clinic,
      autoclaves
    });

    await user.save();

    res.json({
      success: true,
      message: "User created successfully"
    });

  } catch (err) {

    console.error(err);

    res.status(500).json({
      error: "Server error"
    });

  }

});

export default router;