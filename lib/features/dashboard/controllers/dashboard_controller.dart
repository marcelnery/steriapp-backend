import 'package:flutter/foundation.dart';
import '../../cycles/controllers/cycles_controller.dart';
import '../../cycles/repositories/cycles_repository.dart';
import '../../cycles/models/cycle_model.dart';
import '../../cycles/parsers/cycle_txt_parser.dart';

class DashboardController {
  final CyclesController cyclesController;
  final ValueNotifier<CycleModel?> lastCycleNotifier = ValueNotifier(null);

  DashboardController({CyclesRepository? repository})
      : cyclesController = CyclesController(repository ?? CyclesRepository()) {
    _updateLastCycle();
    cyclesController.cyclesNotifier.addListener(_updateLastCycle);
  }

  void _updateLastCycle() {
    lastCycleNotifier.value = cyclesController.lastCycle;
  }

  void dispose() {
    lastCycleNotifier.dispose();
    cyclesController.dispose();
  }

  /// Método de teste: ler um TXT simulado e adicionar ao repository
  void simulateTxtImport(String txtContent) {
    try {
      final parser = CycleTxtParser();
      final cycle = parser.parse(txtContent); // Profissa: parse automático
      cyclesController.addCycle(cycle);
    } catch (e) {
      debugPrint('Erro ao parsear TXT: $e');
    }
  }
}
