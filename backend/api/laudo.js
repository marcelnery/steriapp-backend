import fs from "fs";
import path from "path";

export default function handler(req, res) {

  const filePath = path.join(process.cwd(), "backend/data/laudos.json");

  if (req.method === "POST") {

    try {

      const data = req.body;

      let laudos = [];

      if (fs.existsSync(filePath)) {
        const raw = fs.readFileSync(filePath);
        laudos = JSON.parse(raw || "[]");
      }

      laudos.push(data);

      fs.writeFileSync(filePath, JSON.stringify(laudos, null, 2));

      return res.status(201).json({
        message: "Laudo salvo",
        data
      });

    } catch (err) {

      return res.status(500).json({
        error: "Erro ao salvar",
        details: err.message
      });

    }

  }

  if (req.method === "GET") {

    try {

      if (!fs.existsSync(filePath)) {
        return res.json({ data: [] });
      }

      const raw = fs.readFileSync(filePath);
      const laudos = JSON.parse(raw || "[]");

      return res.json({
        data: laudos
      });

    } catch (err) {

      return res.status(500).json({
        error: "Erro ao ler dados"
      });

    }

  }

}