import express from "express";
import User from "../models/user.js";
import bcrypt from "bcryptjs";
import {sendWelcomeEmail} from "../services/welcomeEmail.service.js"

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
  cpf,
  cro,
  operator,
  autoclaves
} = req.body;

    // =========================
    // VERIFICAR SE USUÁRIO EXISTE
    // =========================

  console.log("CPF RECEBIDO:", cpf);
  console.log("OPERATOR RECEBIDO:", operator);
    const normalizedNickname = nickname.toLowerCase().trim();
    const existingNickname = await User.findOne({ nickname: normalizedNickname });

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
  nickname: normalizedNickname,
  email,
  password: hashedPassword, // cripto a criptografia deu certo para o app 04/05/2026
  clinic,
  cnpj,
  address,
  phone,
  dentist,
  cpf,
  cro,
  operator,
    autoclaves: (autoclaves || []).map(a => ({
    brand: a.brand || a.marca,
    model: a.model || a.modelo,
    serial: a.serial || a.seriado
  }))
});
    await user.save();

    await sendWelcomeEmail(user);

    console.log("======USUARIO SALVO=======");
    console.log(user);

    const savedUser = await User.findById(user._id);       

    console.log("====== USUARIO LIDO DO MONGO ======");    // teste para ver o mongo 13/06 operador e cpf
    console.log(savedUser);

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