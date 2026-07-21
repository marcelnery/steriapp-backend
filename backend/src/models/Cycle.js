import mongoose from 'mongoose';

const CycleStageSchema = new mongoose.Schema({
  stage: String,
  time: String,
  temperature1: Number,
  temperature2: Number,
  pressure: Number,
});

const CycleSchema = new mongoose.Schema(
  {
    id: { type: String, required: true, unique: true },

    userId: {
              type: mongoose.Schema.Types.ObjectId,        // ADICIONADO ID PARA CICLOS VINCULAR COM USER 06/05/2026
              ref: "User",
              required: true,
            },

    clinic: String,
    dentist: String,  // NOVOS CAMPOS ADICIONADOS PARA O CYCLE DETAIL PAGE 18/07
    operator: String,


    cycleNumber: Number,

    model: String,
    serialNumber: String,
    format: String,
    version: String,
    firmware: String,
    equipmentName: String,

    program: String,

    sterilizationTemperature: Number,
    sterilizationTime: Number,
    vacuumTime: Number,
    dryTime: Number,

    sterTemp: Number,
    sterTime: Number,

    maxTemperature: Number,
    maxTemperature2: Number,
    maxPressure: Number,

    startTime: Date,
    endTime: Date,
    rawDateTime: String,

    result: String,
    errorCode: String,

    isCompleteCycle: Boolean,
    isValid: Boolean,

    stages: [CycleStageSchema],
  },
  { timestamps: true }
);

export default mongoose.model('Cycle', CycleSchema);
