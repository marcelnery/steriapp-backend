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

    cycleNumber: Number,

    model: String,
    serialNumber: String,
    version: String,
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
