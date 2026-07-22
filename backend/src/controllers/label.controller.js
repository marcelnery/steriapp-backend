import path from "path";
import { fileURLToPath } from "url";
import Cycle from "../models/Cycle.js";

// =======================================
// __dirname para ES Modules
// =======================================

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// =======================================
// ABRIR ETIQUETA
// =======================================

export async function openLabel(req, res) {

  try {

    const serial = decodeURIComponent(req.params.serial)
      .replace(/SN\.:?/gi, "")
      .replace(/SN:?/gi, "")
      .replace(/:/g, "")
      .replace(/\s/g, "")
      .trim()
      .toUpperCase();

    const cycleNumber = Number(req.params.cycle);

    console.log("Etiqueta consultada:");
    console.log("Serial:", serial);
    console.log("Ciclo :", cycleNumber);

    // ==================================================
    // (Nesta primeira versão procura apenas pelo ciclo)
    // Na próxima etapa vamos procurar por:
    // serial + cycleNumber + userId
    // ==================================================

    const cycle = await Cycle.findOne({
      cycleNumber,
    });

    if (!cycle) {

      return res.sendFile(
        path.join(__dirname, "../public/label_pending.html")
      );

    }

    return res.redirect(`/laudo/${cycle.id}`);

  } catch (err) {

    console.error("Erro openLabel:", err);

    return res.status(500).send("Erro interno do servidor");

  }

}