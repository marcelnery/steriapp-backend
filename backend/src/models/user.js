// GUARDA E SALVA NA WEB USUARIO EMAIL PASSWORD CLINICA E AUTOCLAVE

import mongoose from "mongoose";

// ==============================
// SCHEMA DA AUTOCLAVE
// ==============================

const autoclaveSchema = new mongoose.Schema({

  brand: {
    type: String,
    required: true
  },

  model: {
    type: String,
    required: true
  },

  serial: {
    type: String,
    required: true
  }

});

// ==============================
// SCHEMA DO USUÁRIO
// ==============================

const userSchema = new mongoose.Schema({

  email: {
    type: String,
    required: true,
    unique: true
  },

  password: {
    type: String,
    required: true
  },

  clinic: {
    type: String
  },

  autoclaves: [autoclaveSchema],

  createdAt: {
    type: Date,
    default: Date.now
  }

});

// ==============================
// EXPORT
// ==============================

export default mongoose.model("User", userSchema);