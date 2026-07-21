import Cycle from "../models/Cycle.js";
import CycleModel from "../models/cycle.model.js";
import User from "../models/user.js";
import { sendErrorEmail } from "../services/emailService.js";

export const saveLaudo = async (req, res) => {

  try {

    const data = req.body;

    // const cycle = new CycleModel(data);  AQUI MUDA O NOVO CICLO PARA ID FUNCIONAR ELE PERTENCE AO USER X 06/05/2026

    // const cycle = new CycleModel({...data, userId: req.userId,}); //AQUI !!!!

    const user = await User.findById(req.userId);

const cycle = new CycleModel({

  ...data,

  userId: req.userId,

  clinic: user.clinic,

  dentist: user.dentist,

  operator: user.operator,

});

    // salva no Mongo
    const saved = await Cycle.create(cycle.toJSON());
   console.log(" JSON FINAL:", cycle.toJSON());
    console.log("✅ Ciclo salvo:", saved.id);

    // 🚨 DETECTA CICLO COM ERRO
    if (saved.result === "ERRO") {

      console.log("⚠️ ERRO detectado no ciclo:", saved.id);

      try {

        const user = await User.findById(req.userId);

        await sendErrorEmail({...saved.toObject(),

            clinic: user.clinic,
            operator: user.operator,
            phone: user.phone,
            email: user.email,
          });

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