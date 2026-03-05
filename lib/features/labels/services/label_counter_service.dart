import 'package:shared_preferences/shared_preferences.dart';

class LabelCounterService {
  static final LabelCounterService instance =
      LabelCounterService._internal();

  LabelCounterService._internal();

  static const _cycleKey = "last_printed_cycle";
  static const _globalKey = "last_global_label_number";

  int _lastPrintedCycle = 0;
  int _lastGlobalNumber = 0;

  int get lastPrintedCycle => _lastPrintedCycle;
  int get lastGlobalNumber => _lastGlobalNumber;

  // ===============================
  // LOAD (ao iniciar app)
  // ===============================
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _lastPrintedCycle = prefs.getInt(_cycleKey) ?? 0;
    _lastGlobalNumber = prefs.getInt(_globalKey) ?? 0;
  }

  // ===============================
  // SALVAR
  // ===============================
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_cycleKey, _lastPrintedCycle);
    await prefs.setInt(_globalKey, _lastGlobalNumber);
  }

  // ===============================
  // CALCULAR PRÓXIMO CICLO
  // ===============================
  int getNextCycle(int lastBleCycle) {
    return lastBleCycle + 1;
  }

  // ===============================
  // GERAR PRÓXIMO NÚMERO GLOBAL
  // ===============================
  int getNextGlobalNumber() {
    return _lastGlobalNumber + 1;
  }

  // ===============================
  // CONFIRMAR IMPRESSÃO
  // ===============================
  Future<void> confirmPrint({
    required int printedCycle,
    required int quantity,
  }) async {
    _lastPrintedCycle = printedCycle;
    _lastGlobalNumber += quantity;

    await _save();
  }
}