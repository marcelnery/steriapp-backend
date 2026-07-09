import '../../cycles/models/cycle_model.dart';
import '../../cycles/repositories/cycles_repository.dart';


class ErrorReportService {

  static Future<void> prepareFactoryReport(CycleModel cycle) async {

  if (cycle.errorCode == null) return;

  final repository = CyclesRepository.instance;

  final user = await repository.getLoggedUser();

  final report = {

    // =========================
    // DADOS DO CLIENTE
    // =========================

    "clinic": user["clinic"],

    "operator": user["operator"],

    "phone": user["phone"],

    "email": user["email"],

    // =========================
    // AUTOCLAVE
    // =========================

    "autoclave_model": cycle.model,

    "serial_number": cycle.serialNumber,

    // =========================
    // CICLO
    // =========================

    "cycle_number": cycle.cycleNumber,

    "error_code": cycle.errorCode,

    "program": cycle.program,

    "date": cycle.startTime.toIso8601String(),

    "result": cycle.result,

    "id": cycle.id,
  };
   // 🔥 Aqui  enviado  backend futuramente
    print("📡 ERRO PARA ENVIAR À FÁBRICA:");
    print(report);

  // aqui continua o POST para o backend
}

}