import express from "express";
import bcrypt from "bcryptjs";
import User from "../models/user.js";

const router = express.Router();

router.post("/reset-password", async (req, res) => {

  try {

    const { token, password } = req.body;

    const user = await User.findOne({
      resetToken: token,
      resetTokenExpires: { $gt: Date.now() }
    });

    if (!user) {
      return res.status(400).json({
        error: "Token inválido"
      });
    }

    user.password =
      await bcrypt.hash(password, 10);

    user.resetToken = null;
    user.resetTokenExpires = null;

    await user.save();

    res.json({
      success: true
    });

  } catch (err) {

    console.error(err);

    res.status(500).json({
      error: "Erro ao redefinir senha"
    });

  }

});

export default router;