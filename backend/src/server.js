import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import mongoose from 'mongoose';
import Cycle from './models/Cycle.js';
import dotenv from 'dotenv';
import laudoRoutes from "./routes/laudo.routes.js";
import registerRoutes from "./routes/register.js";
import authRoutes from "./routes/auth.js";
import User from "./models/user.js";
import autoclaveRoutes from "./routes/autoclave.js";
import forgotPasswordRoutes from "./routes/forgot-password.js";
import resetPasswordRoutes from "./routes/reset-password.js";

import { authMiddleware } from "./middleware/auth.middleware.js";  // NOVA ROTA CRIADA PARA ID UNICO 04/05

import laudosGetRoutes from "./routes/laudos.get.js";  // criado para o dashboard html ver ciclos 

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

app.get('/debug-path', (req, res) => {
  res.json({
    
      cwd: process.cwd(),
      dirname: __dirname,
    
});
});



app.get('/', (req, res) => {
  res.send('🚀 Backend SteriLink rodando com sucesso AGORA');
});

app.use("/api", registerRoutes);
app.use("/api", authRoutes); // rota para login
app.use("/api", autoclaveRoutes); // rota para adicionar e excluir autoclave no CAD
app.use("/api", forgotPasswordRoutes); // rota para mudar a senha 
app.use("/api", resetPasswordRoutes); // rota para redirecionar senha e email
app.use("/api",laudosGetRoutes); // rota para ciclos no dashboard html

// ===============================
// GET USER DATA                   nova rota para pegar o CAD do cliente 23/03 NOVA ATT 04/05 ID UNICO RETIRADA DO EMAIL
// ===============================

app.get("/api/user", authMiddleware, async (req, res) => {
  try {

    const user = await User.findById(req.userId);

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json(user);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});


// ===============================
// GET – PAGINAÇÃO DE CICLOS (MONGO)           // FEITO UMA ALTERAÇÃO IMPORTANTE PARA CICLO X SER DO USUARIO X 10/05/2026
// ===============================
app.get('/laudos',authMiddleware, async (req, res) => {
  const page = Number(req.query.page) || 1;
  const limit = Number(req.query.limit) || 10;
  const skip = (page - 1) * limit;

  const total = await Cycle.countDocuments({userId: req.userId});

  const data = await Cycle.find({userId: req.userId})
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