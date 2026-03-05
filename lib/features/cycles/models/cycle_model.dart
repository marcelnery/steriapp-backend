import 'dart:core'; 

class CycleModel {
  // ===============================
  // IDENTIFICAÇÃO ÚNICA (QR CODE)
  // ===============================
  final String id;
  final String publicUrl;

  // ===============================
  // IDENTIFICAÇÃO DO CICLO
  // ===============================
  final int cycleNumber;

  // ===============================
  // IDENTIFICAÇÃO DO EQUIPAMENTO
  // ===============================
  final String model;
  final String serialNumber;
  final String version;
  final String? equipmentName;

  // ===============================
  // PROGRAMA
  // ===============================
  final String program;

  // ===============================
  // PARÂMETROS CONFIGURADOS
  // ===============================
  final double sterilizationTemperature;
  final int sterilizationTime;
  final int vacuumTime;
  final int dryTime;

  // ===============================
  // ALIASES (UI)
  // ===============================
  final double sterTemp;
  final int sterTime;

  // ===============================
  // VALORES MEDIDOS
  // ===============================
  final double maxTemperature;
  final double maxTemperature2;
  final double maxPressure;

  // ===============================
  // DATAS
  // ===============================
  final DateTime startTime;
  final DateTime endTime;
  final String? rawDateTime;

  // ===============================
  // RESULTADO
  // ===============================
  final String result;
  final String? errorCode;

  // ===============================
  // ETAPAS
  // ===============================
  final List<CycleStageModel> stages;

  // ===============================
  // CONTROLES
  // ===============================
  final bool isCompleteCycle;
  final bool isValid;

  CycleModel({
    required this.id,
    required this.cycleNumber,
    required this.model,
    required this.serialNumber,
    required this.version,
    required this.program,
    required this.sterilizationTemperature,
    required this.sterilizationTime,
    required this.vacuumTime,
    required this.dryTime,
    required this.sterTemp,
    required this.sterTime,
    required this.maxTemperature,
    required this.maxTemperature2,
    required this.maxPressure,
    required this.startTime,
    required this.endTime,
    required this.result,
    required this.stages,
    this.errorCode,
    this.equipmentName,
    this.rawDateTime,
    this.isCompleteCycle = true,
    this.isValid = true,
  }) : publicUrl = _buildPublicUrl(id);

  // ======================================================
  // 🔵 FROM JSON (BACKEND)
  // ======================================================
  factory CycleModel.fromJson(Map<String, dynamic> json) {
    return CycleModel(
      id: json['id']?.toString() ?? '',
      cycleNumber: json['cycleNumber'] ?? 0,
      model: json['model']?.toString() ?? '',
      serialNumber: json['serialNumber']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      equipmentName: json['equipmentName']?.toString(),
      program: json['program']?.toString() ?? '',
      sterilizationTemperature:
          (json['sterilizationTemperature'] as num?)?.toDouble() ?? 0,
      sterilizationTime: json['sterilizationTime'] ?? 0,
      vacuumTime: json['vacuumTime'] ?? 0,
      dryTime: json['dryTime'] ?? 0,
      sterTemp: (json['sterTemp'] as num?)?.toDouble() ?? 0,
      sterTime: json['sterTime'] ?? 0,
      maxTemperature:
          (json['maxTemperature'] as num?)?.toDouble() ?? 0,
      maxTemperature2:
          (json['maxTemperature2'] as num?)?.toDouble() ?? 0,
      maxPressure:
          (json['maxPressure'] as num?)?.toDouble() ?? 0,
      startTime: DateTime.tryParse(json['startTime'] ?? '') ??
          DateTime.now(),
      endTime:
          DateTime.tryParse(json['endTime'] ?? '') ?? DateTime.now(),
      rawDateTime: json['rawDateTime']?.toString(),
      result: json['result']?.toString() ?? '',
      errorCode: json['errorCode']?.toString(),
      isCompleteCycle: json['isCompleteCycle'] ?? true,
      isValid: json['isValid'] ?? true,
      stages: (json['stages'] as List<dynamic>? ?? [])
          .map((e) =>
              CycleStageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ======================================================
  // 🟢 FROM JSON (BLE / ESP32)
  // ======================================================
  factory CycleModel.fromBleJson(Map<String, dynamic> json) {

  final payload = json;

  final String cycleStr =
      payload['cycle']?.toString() ?? 'EVENT';

  final int cycleNumber =
      int.tryParse(cycleStr) ?? 0;

  final String serial =
      payload['serial']?.toString().trim().isNotEmpty == true
          ? payload['serial'].toString()
          : "UNKNOWN";

  final String date =
      payload['date']?.toString() ?? "NODATE";

  final String status =
      payload['status']?.toString() ?? "unknown";

  /// ✅ ID PROFISSIONAL (NÃO MUDA NUNCA)
  final String id = "$serial|$date|$cycleStr|$status";

  final DateTime now = DateTime.now();

  return CycleModel(
    id: id,
    cycleNumber: cycleNumber,
    model: payload['model']?.toString() ?? '',
    serialNumber: serial,
    version: '',
    program: payload['program']?.toString() ?? '',
    sterilizationTemperature:
        (payload['ster_temp'] as num?)?.toDouble() ?? 0,
    sterilizationTime: payload['ster_time'] ?? 0,
    vacuumTime: payload['vac_times'] ?? 0,
    dryTime: payload['dry_time'] ?? 0,
    sterTemp:
        (payload['ster_temp'] as num?)?.toDouble() ?? 0,
    sterTime: payload['ster_time'] ?? 0,
    maxTemperature:
        (payload['max_temp'] as num?)?.toDouble() ?? 0,
    maxTemperature2:
        (payload['min_temp'] as num?)?.toDouble() ?? 0,
    maxPressure:
        (payload['max_press'] as num?)?.toDouble() ?? 0,
    startTime: now,
    endTime: now,
    result: status == 'success'
        ? 'SUCESSO'
        : 'ERRO',
    errorCode: payload['error']?.toString(),
    stages: (payload['stages'] as List<dynamic>? ?? [])
        .map((e) => CycleStageModel.fromJson({
              'stage': e['stage'] ?? '',
              'time': e['time'] ?? '',
              'temperature1': e['temperature1'] ?? 0,
              'temperature2': e['temperature2'] ?? 0,
              'pressure': e['pressure'] ?? 0,
            }))
        .toList(),
  );
}
  // ======================================================
  // 🔵 TO JSON (ENVIO BACKEND)
  // ======================================================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cycleNumber': cycleNumber,
      'model': model,
      'serialNumber': serialNumber,
      'version': version,
      'equipmentName': equipmentName,
      'program': program,
      'sterilizationTemperature': sterilizationTemperature,
      'sterilizationTime': sterilizationTime,
      'vacuumTime': vacuumTime,
      'dryTime': dryTime,
      'sterTemp': sterTemp,
      'sterTime': sterTime,
      'maxTemperature': maxTemperature,
      'maxTemperature2': maxTemperature2,
      'maxPressure': maxPressure,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'rawDateTime': rawDateTime,
      'result': result,
      'errorCode': errorCode,
      'isCompleteCycle': isCompleteCycle,
      'isValid': isValid,
      'stages': stages.map((s) => s.toJson()).toList(),
    };
  }

  static String _buildPublicUrl(String id) {
    return 'https://backend-nu-nine-29.vercel.app/laudo/$id';
  }

  Uri get publicUri => Uri.parse(publicUrl);
}

// =======================================================
// STAGE MODEL
// =======================================================
class CycleStageModel {
  final String stage;
  final String time;
  final double temperature1;
  final double temperature2;
  final double pressure;

  CycleStageModel({
    required this.stage,
    required this.time,
    required this.temperature1,
    required this.temperature2,
    required this.pressure,
  });

  factory CycleStageModel.fromJson(Map<String, dynamic> json) {
    return CycleStageModel(
      stage: json['stage']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      temperature1:
          (json['temperature1'] as num?)?.toDouble() ?? 0,
      temperature2:
          (json['temperature2'] as num?)?.toDouble() ?? 0,
      pressure:
          (json['pressure'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage': stage,
      'time': time,
      'temperature1': temperature1,
      'temperature2': temperature2,
      'pressure': pressure,
    };
  }
}