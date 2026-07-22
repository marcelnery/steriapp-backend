import path from "path";
import { fileURLToPath } from "url";
import Cycle from "../models/Cycle.js";

const __filename = fileURLToPath(import.meta.url);
const _dirname = path.dirname(_filename);

export async function openLabel(req, res) {

    try {

        const serial = decodeURIComponent(req.params.serial)
            .replace(/:/g, "")
            .trim()
            .toUpperCase();

        const cycleNumber = Number(req.params.cycle);

        const cycle = await Cycle.findOne({
            cycleNumber: cycleNumber,
        });

        if (!cycle) {

            return res.sendFile(
                path.join(__dirname, "..", "public", "label_pending.html")
            );
        }

        return res.redirect(`/laudo/${cycle.id}`);

    } catch (err) {

        console.error(err);

        return res.status(500).send("Erro interno");

    }

}