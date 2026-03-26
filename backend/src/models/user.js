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

  nickname: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },

   email: {
    type: String,
    required: true,
    unique: true
  },

  password: {
    type: String,
    required: true
  },

  clinic: String,

  cnpj: String,

  address: {
    street: String,
    district: String,
    city: String,
    state: String,
  },

  phone: String,

  dentist: String,

  cro: String,

  autoclaves: {
  type: [autoclaveSchema],
  default: []
  },

  createdAt: {
    type: Date,
    default: Date.now
  }

});

// ==============================
// EXPORT
// ==============================

export default mongoose.model("User", userSchema);