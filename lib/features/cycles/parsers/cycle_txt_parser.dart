import '../models/cycle_model.dart';

class CycleTxtParser {
  CycleModel parse(String txt) {
    try {
      final lines = txt
          .replaceAll('\r', '')
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      // ===============================
      // HEADER
      // ===============================
      String version = '';
      String model = '';
      String serialNumber = '';
      String program = '';
      DateTime date = DateTime.now();
      int cycleNumber = 0;

      // ===============================
      // PARÂMETROS
      // ===============================
      double sterilizationTemperature = 0;
      int sterilizationTime = 0;
      int vacuumTime = 0;
      int dryTime = 0;

      // ===============================
      // RESULTADO
      // ===============================
      String result = 'SUCESSO';
      String? errorCode;

      for (final line in lines) {
        if (line.startsWith('Medical Report')) {
          version = line.split(' ').last;
        } else if (line.startsWith('Model')) {
          model = _afterColon(line);
        } else if (line.startsWith('SN')) {
          serialNumber = _afterColon(line);
        } else if (line.startsWith('Program')) {
          program = _afterColon(line);
        } else if (line.startsWith('Date')) {
          date = _safeParseDate(_afterColon(line));
        } else if (line.startsWith('Cycle')) {
          cycleNumber = int.tryParse(_afterColon(line)) ?? 0;
        } else if (line.startsWith('Ster Temp')) {
          sterilizationTemperature =
              double.tryParse(_afterColon(line)) ?? 0;
        } else if (line.startsWith('Ster Time')) {
          sterilizationTime = int.tryParse(_afterColon(line)) ?? 0;
        } else if (line.startsWith('Vacuum Time')) {
          vacuumTime = int.tryParse(_afterColon(line)) ?? 0;
        } else if (line.startsWith('Dry Time')) {
          dryTime = int.tryParse(_afterColon(line)) ?? 0;
        } else if (line.startsWith('Error')) {
          result = 'FALHA';
          errorCode = _afterColon(line);
        }
      }

      // ===============================
      // STAGES
      // ===============================
      final List<CycleStageModel> stages = [];
      double maxTemp1 = 0;
      double maxTemp2 = 0;
      double maxPressure = 0;

      for (final line in lines) {
        if (line.startsWith('STAG') ||
            line.startsWith('TIME') ||
            line.startsWith('---')) {
          continue;
        }

        final cols = line.split(RegExp(r'\s+'));
        if (cols.length < 5) continue;

        final t1 = double.tryParse(cols[2]) ?? 0;
        final t2 = double.tryParse(cols[3]) ?? 0;
        final p = double.tryParse(cols[4]) ?? 0;

        stages.add(
          CycleStageModel(
            stage: cols[0],
            time: cols[1],
            temperature1: t1,
            temperature2: t2,
            pressure: p,
          ),
        );

        if (t1 > maxTemp1) maxTemp1 = t1;
        if (t2 > maxTemp2) maxTemp2 = t2;
        if (p > maxPressure) maxPressure = p;
      }

      final formattedDate =
          '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

      final id =
          '${serialNumber.isNotEmpty ? serialNumber : 'SN'}-C${cycleNumber.toString().padLeft(3, '0')}-$formattedDate';

      return CycleModel(
        id: id,
        cycleNumber: cycleNumber,
        model: model,
        serialNumber: serialNumber,
        version: version,
        program: program.isNotEmpty ? program : 'Esterilização',
        sterilizationTemperature: sterilizationTemperature,
        sterilizationTime: sterilizationTime,
        vacuumTime: vacuumTime,
        dryTime: dryTime,
        sterTemp: sterilizationTemperature,
        sterTime: sterilizationTime,
        maxTemperature: maxTemp1,
        maxTemperature2: maxTemp2,
        maxPressure: maxPressure,
        startTime: date,
        endTime: date,
        result: result,
        errorCode: errorCode,
        stages: stages,
        isCompleteCycle: stages.isNotEmpty,
        isValid: result == 'SUCESSO',
      );
    } catch (e) {
      throw Exception('Erro ao parsear TXT: $e');
    }
  }

  String _afterColon(String line) {
    final i = line.indexOf(':');
    return i == -1 ? '' : line.substring(i + 1).trim();
  }

  /// Parser de data ultra tolerante
  DateTime _safeParseDate(String raw) {
    try {
      final cleaned =
          raw.replaceAll(RegExp(r'[^0-9/-]'), '').trim();

      if (cleaned.contains('-')) {
        final p = cleaned.split('-');
        if (p[0].length == 4) {
          return DateTime(
              int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
        } else {
          return DateTime(
              int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
        }
      }

      if (cleaned.contains('/')) {
        final p = cleaned.split('/');
        return DateTime(
            int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      }
    } catch (_) {}

    return DateTime.now();
  }
}
