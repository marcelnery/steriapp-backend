// src/models/cycle.model.js

export default class CycleModel {
  constructor(data) {
    // ===============================
    // IDENTIFICAÇÃO ÚNICA (QR CODE)
    // ===============================
    this.id = data.id; // Ex: SN123-C001-20260105

    this.userId = data.userId;          // MUDANCA IMPORTANTE PARA IDENTIFICACAO DO USUARIO PARA CILCOS 07/05/2026

    this.clinic = data.clinic || "";
    this.dentist = data.dentist || "";
    this.operator = data.operator || "";

    // ===============================
    // IDENTIFICAÇÃO DO CICLO
    // ===============================

    this.cycleNumber = Number(data.cycleNumber);

    // ===============================
    // IDENTIFICAÇÃO DO EQUIPAMENTO
    // ===============================
    this.model = data.model;
    this.serialNumber = data.serialNumber;
     this.format = data.format || "";
    this.version = data.version || "";
     this.firmware = data.firmware || this.version ||"";
    this.equipmentName = data.equipmentName || null;

    // ===============================
    // PROGRAMA
    // ===============================
    this.program = data.program;

    // ===============================
    // PARÂMETROS CONFIGURADOS
    // ===============================
    this.sterilizationTemperature = Number(
      data.sterilizationTemperature
    );
    this.sterilizationTime = Number(data.sterilizationTime);
    this.vacuumTime = Number(data.vacuumTime);
    this.dryTime = Number(data.dryTime);

    // ===============================
    // ALIASES (UI)
    // ===============================
 this.sterTemp = data.sterTemp !== undefined ? Number(data.sterTemp) : null;
this.sterTime = data.sterTime !== undefined ? Number(data.sterTime) : null;

    // ===============================
    // VALORES MEDIDOS
    // ===============================
    this.maxTemperature = Number(data.maxTemperature);
    this.maxTemperature2 = Number(data.maxTemperature2);
    this.maxPressure = Number(data.maxPressure);

    // ===============================
    // DATAS
    // ===============================
    this.startTime = new Date(data.startTime);
    this.endTime = new Date(data.endTime);
    this.rawDateTime = data.rawDateTime || null;

    // ===============================
    // RESULTADO
    // ===============================
    this.result = data.result;
    this.errorCode = data.errorCode || null;

    // ===============================
    // ETAPAS
    // ===============================
    this.stages = Array.isArray(data.stages)
      ? data.stages.map((s) => ({
          stage: s.stage,
          time: s.time,
          temperature1: Number(s.temperature1),
          temperature2: Number(s.temperature2),
          pressure: Number(s.pressure),
        }))
      : [];

    // ===============================
    // CONTROLES
    // ===============================
    this.isCompleteCycle =
      data.isCompleteCycle !== undefined
        ? Boolean(data.isCompleteCycle)
        : true;

    this.isValid =
      data.isValid !== undefined ? Boolean(data.isValid) : true;

    // ===============================
    // URL PÚBLICA DO LAUDO
    // ===============================
    this.publicUrl = this.buildPublicUrl();
  }

  // ===============================
  // URL DO LAUDO (QR CODE)
  // ===============================
  buildPublicUrl() {
    return `https://backend-nu-nine-29.vercel.app/laudo/${this.id}`;
  }

  // ===============================
  // SERIALIZAÇÃO (API / DB)
  // ===============================
  toJSON() {
    return {
      id: this.id,
      userId: this.userId,
      clinic: this.clinic,
      dentist: this.dentist,
      operator: this.operator,
      cycleNumber: this.cycleNumber,

      model: this.model,
      serialNumber: this.serialNumber,
      format: this.format,
      version: this.version,
      firmware: this.firmware,
      equipmentName: this.equipmentName,

      program: this.program,

      sterilizationTemperature: this.sterilizationTemperature,
      sterilizationTime: this.sterilizationTime,
      vacuumTime: this.vacuumTime,
      dryTime: this.dryTime,

      sterTemp: this.sterTemp,
      sterTime: this.sterTime,

      maxTemperature: this.maxTemperature,
      maxTemperature2: this.maxTemperature2,
      maxPressure: this.maxPressure,

      startTime: this.startTime.toISOString(),
      endTime: this.endTime.toISOString(),
      rawDateTime: this.rawDateTime,

      result: this.result,
      errorCode: this.errorCode,

      stages: this.stages,

      isCompleteCycle: this.isCompleteCycle,
      isValid: this.isValid,

      publicUrl: this.publicUrl,
    };
  }
}
