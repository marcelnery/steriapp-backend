import 'package:flutter/foundation.dart';
import '../models/cycle_model.dart';
import '../repositories/cycles_repository.dart';

/// Controller profissa 😎 responsável pelo gerenciamento
/// do estado dos ciclos
class CyclesController {
  final CyclesRepository _repository;

  /// Notifier que a UI escuta
  final ValueNotifier<List<CycleModel>> cyclesNotifier =
      ValueNotifier<List<CycleModel>>([]);

  CyclesController(this._repository) {
    _loadInitialData();
  }

  void _loadInitialData() {
    cyclesNotifier.value = _repository.getAllCycles();
  }

  /// Adiciona novo ciclo
  void addCycle(CycleModel cycle) {
    _repository.addCycle(cycle);
    _refresh();
  }

  /// Remove ciclo pelo número do ciclo
  void removeCycleByNumber(int cycleNumber) {
    _repository.removeCycleByNumber(cycleNumber);
    _refresh();
  }

  /// Limpa todos os ciclos
  void clearHistory() {
    _repository.clearAll();
    _refresh();
  }

  /// Retorna o último ciclo (para dashboard)
  CycleModel? get lastCycle => _repository.getLastCycle();

  void _refresh() {
    cyclesNotifier.value = _repository.getAllCycles();
  }

  void dispose() {
    cyclesNotifier.dispose();
  }
}
