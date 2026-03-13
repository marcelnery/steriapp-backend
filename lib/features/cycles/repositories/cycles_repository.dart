import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/cycle_model.dart';
import '../parsers/cycle_txt_parser.dart';

class CyclesRepository {
  // =========================
  // SINGLETON
  // =========================
  static final CyclesRepository instance = CyclesRepository._internal();
  factory CyclesRepository() => instance;
  CyclesRepository._internal();

  // =========================
  // STATE
  // =========================
  final List<CycleModel> _cycles = [];
  final CycleTxtParser _parser = CycleTxtParser();

  static const String baseUrl =
      'https://backend-nu-nine-29.vercel.app';

  // =========================
  // LOAD TXT (LEGADO / ESP32)
  // =========================
  Future<void> loadMultipleFromAssets(List<String> assetPaths) async {
    _cycles.clear();

    for (final path in assetPaths) {
      try {
        final data = await rootBundle.load(path);
        final bytes = data.buffer.asUint8List();
        final txt = latin1.decode(bytes, allowInvalid: true);

        final cycle = _parser.parse(txt);
        _cycles.add(cycle);
      } catch (e) {
        throw Exception('Erro ao carregar arquivo $path: $e');
      }
    }
  }

  // =========================
  // BACKEND – PAGINAÇÃO REAL
  // =========================
 Future<List<CycleModel>> fetchCycles({
  int page = 1,
  int limit = 10,
  bool clearBefore = false,
}) async {

  final uri = Uri.parse(
    '$baseUrl/api/laudos?page=$page&limit=$limit',
  );

  try {

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception();
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    final List<dynamic> data = json['data'] ?? [];

    final List<CycleModel> newCycles = data
        .map((e) => CycleModel.fromJson(e))
        .toList();

    if (clearBefore) {
      _cycles.clear();
    }

    _cycles.addAll(newCycles);
    return newCycles;

  } catch (_) {

    print("⚠️ Backend offline — usando cache local");
    return _cycles;
  }
}

  // =========================
  // ADD FROM BLE JSON
  // =========================
  
/* CycleModel? addFromBleJson(Map<String, dynamic> json) {

  final cycle = CycleModel.fromBleJson(json);

  if (exists(cycle.id)) {
    print("⚠️ Ciclo já recebido: ${cycle.id}");
    return null;
  }

  _cycles.add(cycle);

  print("✅ Novo ciclo BLE: ${cycle.id}");

  return cycle;
}

*/

CycleModel? addFromBleJson(Map<String, dynamic> json) {

  final cycle = CycleModel.fromBleJson(json);

  if (exists(cycle.id)) {
    print("⚠️ Ciclo já recebido: ${cycle.id}");
    return null;
  }

  _cycles.add(cycle);

  print("✅ Novo ciclo BLE: ${cycle.id}");

  // 🔵 ENVIAR PARA BACKEND
  sendToBackend(cycle).catchError((_) {
    print("⚠️ Backend offline — salvo local");
  });

  return cycle;
}
  // =========================
  // CHECAR EXISTÊNCIA
  // =========================
  bool exists(String id) {
    return _cycles.any((c) => c.id == id);
  }

  // =========================
  // SEND TO BACKEND
  // =========================
  Future<void> sendToBackend(CycleModel cycle) async {
    final uri = Uri.parse('$baseUrl/api/laudo');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cycle.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Erro ao enviar ciclo para o backend (${response.statusCode})');
    }

    print('🌐 Ciclo salvo no backend/Mongo: ${cycle.id}');
  }

  // =========================
// ADD LOCAL
// =========================
void addCycle(CycleModel cycle) {
  _cycles.add(cycle);
}

// =========================
// REMOVE BY CYCLE NUMBER
// =========================
void removeCycleByNumber(int cycleNumber) {
  _cycles.removeWhere((c) => c.cycleNumber == cycleNumber);
}

  // =========================
  // CRUD LOCAL
  // =========================
  List<CycleModel> getAllCycles() => List.unmodifiable(_cycles);

  void clearAll() => _cycles.clear();

  CycleModel? getLastCycle() {
    if (_cycles.isEmpty) return null;
    return _cycles.last;
  }

  // =========================
  // LOOKUPS
  // =========================
  CycleModel findById(String id) {
    return _cycles.firstWhere(
      (c) => c.id == id,
      orElse: () => throw Exception('Ciclo não encontrado (id=$id)'),
    );
  }

  // =========================
// FIND BY CYCLE NUMBER
// =========================
CycleModel findByCycleNumber(String cycleNumber) {
  return _cycles.firstWhere(
    (c) => c.cycleNumber.toString() == cycleNumber,
    orElse: () =>
        throw Exception('Ciclo não encontrado (número=$cycleNumber)'),
  );
}
}