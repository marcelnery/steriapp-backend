import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import mongoose from 'mongoose';
import Cycle from './models/Cycle.js';
import dotenv from 'dotenv';
import laudoRoutes from "./routes/laudo.routes.js";
import registerRoutes from "./routes/register.js";


dotenv.config();


// ===============================
// MONGODB CONNECTION (SERVERLESS SAFE)
// ===============================

const MONGODB_URI = process.env.MONGODB_URI;

let cached = global.mongoose;

if (!cached) {
  cached = global.mongoose = { conn: null, promise: null };
}

async function connectMongo() {
  if (cached.conn) {
    return cached.conn;
  }

  if (!cached.promise) {
    cached.promise = mongoose.connect(MONGODB_URI).then((mongoose) => {
      console.log("✅ MongoDB conectado");
      return mongoose;
    });
  }

  cached.conn = await cached.promise;
  return cached.conn;
}

connectMongo();

// ===============================
// CONFIG
// ===============================
const app = express();
const PORT = process.env.PORT || 3000;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// ===============================
// MIDDLEWARE
// ===============================
app.use(cors());
app.use(express.json());
const publicPath = path.join(process.cwd(), 'src/public');
app.use(express.static(publicPath));

app.use("/api", laudoRoutes); // mudanca de rota para api 12/03
// ===============================
// ROTA RAIZ
// ===============================
app.get('/', (req, res) => {
  res.send('🚀 Backend SteriLink rodando com sucesso AGORA');
});

app.use("/api", registerRoutes);


// ===============================
// GET – PAGINAÇÃO DE CICLOS (MONGO)
// ===============================
app.get('/laudos', async (req, res) => {
  const page = Number(req.query.page) || 1;
  const limit = Number(req.query.limit) || 10;
  const skip = (page - 1) * limit;

  const total = await Cycle.countDocuments();

  const data = await Cycle.find()
    .sort({ startTime: -1 })
    .skip(skip)
    .limit(limit);

  return res.json({
    page,
    limit,
    total,
    data,
  });
});

// ===============================
// GET – JSON DO LAUDO (MONGO)
// ===============================
app.get('/api/laudo/:id', async (req, res) => {
  const laudo = await Cycle.findOne({ id: req.params.id });

  if (!laudo) {
    return res.status(404).json({
      error: 'Laudo não encontrado',
    });
  }

  return res.json(laudo);
});

// ===============================
// GET – HTML DO LAUDO (QR CODE)
// ===============================
app.get('/laudo/:id', async (req, res) => {
  const laudo = await Cycle.findOne({ id: req.params.id });

  if (!laudo) {
    return res.status(404).send('Laudo não encontrado');
  }

  return res.sendFile(path.join(__dirname, 'public', 'laudo.html'));
});

// ===============================
// START LOCAL
// ===============================
if (process.env.NODE_ENV !== 'production') {
  app.listen(PORT, () => {
    console.log(`🚀 Backend rodando em http://localhost:${PORT}`);
  });
}

export default app;