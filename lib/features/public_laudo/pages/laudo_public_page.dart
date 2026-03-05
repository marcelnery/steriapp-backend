import 'package:flutter/material.dart';
import '../../cycles/models/cycle_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class LaudoPublicPage extends StatelessWidget {
  final CycleModel cycle;

  const LaudoPublicPage({
    super.key,
    required this.cycle,
  });

  /// Usado quando a página é aberta por URL / Deep Link
  factory LaudoPublicPage.fromCycle(CycleModel cycle) {
    return LaudoPublicPage(cycle: cycle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laudo do Ciclo #${cycle.cycleNumber}'),
        backgroundColor: const Color(0xFF5E2B97),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Identificação'),
            _card([
              _row('Modelo', cycle.model),
              _row('Serial', cycle.serialNumber),
              _row('Programa', cycle.program),
              _row('Data', _formatDate(cycle.startTime)),
            ]),

            const SizedBox(height: 16),

            _sectionTitle('Parâmetros'),
            _card([
              _row(
                'Temp. Esterilização',
                '${cycle.sterilizationTemperature} °C',
              ),
              _row(
                'Tempo Esterilização',
                '${cycle.sterilizationTime} min',
              ),
              _row('Vácuo', '${cycle.vacuumTime} min'),
              _row('Secagem', '${cycle.dryTime} min'),
            ]),

            const SizedBox(height: 16),

            _sectionTitle('Valores Medidos'),
            _card([
              _row(
                'Temp. Máx. Sensor 1',
                '${cycle.maxTemperature} °C',
              ),
              _row(
                'Temp. Máx. Sensor 2',
                '${cycle.maxTemperature2} °C',
              ),
              _row(
                'Pressão Máx.',
                '${cycle.maxPressure} bar',
              ),
            ]),

            const SizedBox(height: 16),

            _sectionTitle('Resultado'),
            _card([
              _row(
                'Status',
                cycle.result,
                valueColor: cycle.result == 'SUCESSO'
                    ? Colors.green
                    : Colors.red,
              ),
              if (cycle.errorCode != null)
                _row(
                  'Código de Erro',
                  cycle.errorCode!,
                  valueColor: Colors.red,
                ),
            ]),

            const SizedBox(height: 24),

            Center(
              child: Text(
                'Documento público para auditoria\nSistema Sterilink · Woson',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // UI HELPERS
  // =========================

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _card(List<Widget> children) => Card(
        elevation: 4,
        margin: const EdgeInsets.only(top: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: children),
        ),
      );

  Widget _row(
    String label,
    String value, {
    Color? valueColor,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
