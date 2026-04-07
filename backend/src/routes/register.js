import express from "express";
import User from "../models/user.js";
import bcrypt from "bcryptjs";

const router = express.Router();

router.post("/register", async (req, res) => {

  console.log("===== BODY RECEBIDO =====");
  console.log(req.body);

  console.log("===== AUTOCLAVES RECEBIDAS =====");
  console.log(req.body.autoclaves);

  try {

    const {
  nickname,
  email,
  password,
  clinic,
  cnpj,
  address,
  phone,
  dentist,
  cro,
  autoclaves
} = req.body;

    // =========================
    // VERIFICAR SE USUÁRIO EXISTE
    // =========================

    const existingNickname = await User.findOne({ nickname });

if (existingNickname) {
  return res.status(400).json({
    error: "Nickname já existe"
  });
}

    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res.status(400).json({
        error: "User already exists"
      });
    }

    // =========================
    // CRIAR USUÁRIO
    // =========================

    // 🔐 gerar hash da senha
const hashedPassword = await bcrypt.hash(password, 10);

 const user = new User({
  nickname,
  email,
  password: hashedPassword, // cripto
  clinic,
  cnpj,
  address,
  phone,
  dentist,
  cro,
    autoclaves: (autoclaves || []).map(a => ({
    brand: a.brand || a.marca,
    model: a.model || a.modelo,
    serial: a.serial || a.seriado
  }))
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