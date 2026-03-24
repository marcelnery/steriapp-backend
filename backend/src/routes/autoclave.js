// adiciona ou remove as autoclaves do cadastro 24/03


import express from "express";
import User from "../models/user.js";

const router = express.Router();


// ===============================
// ➕ ADICIONAR AUTOCLAVE
// ===============================
router.post("/user/add-autoclave", async (req, res) => {

  try {
    const { email, brand, model, serial } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // 🔒 Evita duplicar serial
    const exists = user.autoclaves.find(a => a.serial === serial);

    if (exists) {
      return res.status(400).json({ error: "Autoclave já cadastrada" });
    }

    user.autoclaves.push({
      brand,
      model,
      serial
    });

    await user.save();

    res.json({ success: true });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao adicionar autoclave" });
  }

});


// ===============================
// 🗑️ REMOVER AUTOCLAVE
// ===============================
router.post("/user/remove-autoclave", async (req, res) => {

  try {
    const { email, serial } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    user.autoclaves = user.autoclaves.filter(
      a => a.serial !== serial
    );

    await user.save();

    res.json({ success: true });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao remover autoclave" });
  }

});

export default router;