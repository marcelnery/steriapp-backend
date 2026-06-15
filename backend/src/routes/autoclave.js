// adiciona ou remove as autoclaves do cadastro 24/03


import express from "express";
import User from "../models/user.js";

import {authMiddleware} from "../middleware/auth.middleware.js";   // NOVA AUTERAÇAO PARA FAZER O DASHBOARD PRINCIPAL DO LOGIN 
// IDENTIFICACAO UNICA DO USUARIO 04/05/2026

const router = express.Router();


// ===============================
// ➕ ADICIONAR AUTOCLAVE
// ===============================

/* ESSA AUTENTICAÇÃO MORREU PARA PQ ESTAVA COM EMAIL E AGORA SERA UM ID CRIADO CRIPTO 04/05/2026

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

*/

router.post("/user/add-autoclave", authMiddleware, async (req, res) => {

  try {

    const { brand, model, serial } = req.body;

    const user = await User.findById(req.userId); // 🔥 NÃO USA MAIS EMAIL

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const exists = user.autoclaves.find(a => a.serial === serial);

    if (exists) {
      return res.status(400).json({ error: "Autoclave já cadastrada" });
    }

    user.autoclaves.push({ brand, model, serial });

    await user.save();

    res.json({ success: true });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erro ao adicionar autoclave" });
  }

});


// ===============================
// 🗑️ REMOVER AUTOCLAVE              TAMBEM FOI ALTERADO 
// ===============================

/*
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

*/

router.post("/user/remove-autoclave", authMiddleware, async (req, res) => {

  try {

    const { serial } = req.body;

    const user = await User.findById(req.userId); // 🔥 NÃO USA EMAIL

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

// ===============================
// 👤 ALTERAR OPERADOR
// ===============================

router.post("/user/update-operator", authMiddleware, async (req, res) => {

  try {

    const { operator } = req.body;

    const user = await User.findById(req.userId);

    if (!user) {
      return res.status(404).json({
        error: "User not found"
      });
    }

    user.operator = operator;

    await user.save();

    res.json({
      success: true
    });

  } catch (err) {

    console.error(err);

    res.status(500).json({
      error: "Erro ao atualizar operador"
    });

  }

});

export default router;