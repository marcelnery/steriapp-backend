import express from "express";
import crypto from "crypto";
import User from "../models/user.js";
import { sendResetPasswordEmail } from "../services/passwordReset.service.js";

const router = express.Router();

router.post("/forgot-password", async (req, res) => {

  try {

    const { email } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.json({
        success: true
      });
    }

    const token = crypto.randomBytes(32).toString("hex");

    user.resetToken = token;
    user.resetTokenExpires =
      Date.now() + 1000 * 60 * 60;

    await user.save();

    await sendResetPasswordEmail(
      user.email,
      token,
      user.nickname,
    );

    res.json({
      success: true
    });

  } catch (err) {

    console.error(err);

    res.status(500).json({
      error: "Erro ao recuperar senha"
    });

  }

});

export default router;