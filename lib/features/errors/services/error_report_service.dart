import '../../cycles/models/cycle_model.dart';

class ErrorReportService {

  static Future<void> prepareFactoryReport(CycleModel cycle) async {

    if (cycle.errorCode == null) return;

    final report = {
      "autoclave_model": cycle.model,
      "serial_number": cycle.serialNumber,
      "cycle_number": cycle.cycleNumber,
      "error_code": cycle.errorCode,
      "program": cycle.program,
      "date": cycle.startTime.toIso8601String(),
      "result": cycle.result,
    };

    // 🔥 Aqui será enviado ao backend futuramente
    print("📡 ERRO PARA ENVIAR À FÁBRICA:");
    print(report);
  }
}