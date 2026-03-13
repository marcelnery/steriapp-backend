import Cycle from "../models/Cycle.js";
import CycleModel from "../models/cycle.model.js";
import { sendErrorEmail } from "../services/emailService.js";

export const saveLaudo = async (req, res) => {

  try {

    const data = req.body;

    const cycle = new CycleModel(data);

    // salva no Mongo
    const saved = await Cycle.create(cycle.toJSON());

    console.log("✅ Ciclo salvo:", saved.id);

    // 🚨 DETECTA CICLO COM ERRO
    if (saved.result === "ERRO") {

      console.log("⚠️ ERRO detectado no ciclo:", saved.id);

      try {

        await sendErrorEmail(saved);

        console.log("📧 Email enviado para fábrica");

      } catch (emailError) {

        console.error("Erro ao enviar email:", emailError);

      }

    }

    res.status(201).json({
      message: "Laudo salvo com sucesso",
      data: saved,
    });

  } catch (error) {

    console.error("Erro real:", error);

    res.status(500).json({
      error: "Erro ao salvar laudo",
    });

  }

};