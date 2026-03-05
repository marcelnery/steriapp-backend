import 'package:flutter/material.dart';
import '../models/cycle_model.dart';
import '../services/cycle_pdf_service.dart';
import '../repositories/cycles_repository.dart';
import '../widgets/cycle_qr_widget.dart';
import '../../errors/data/error_codes.dart';

class CycleDetailPage extends StatelessWidget {
  final CycleModel cycle;

  const CycleDetailPage({
    super.key,
    required this.cycle,
  });

  factory CycleDetailPage.fromDeepLink(String cycleNumber) {
    final cycle = CyclesRepository.instance.findByCycleNumber(cycleNumber);
    return CycleDetailPage(cycle: cycle);
  }

  @override
  Widget build(BuildContext context) {
    const wosonPurple = Color(0xFF5E2B97);

    return Scaffold(
      appBar: AppBar(
       title: Text(
                   'Ciclo #${cycle.cycleNumber}',
                     style: const TextStyle(
                            color: Colors.white,
                             fontWeight: FontWeight.bold,
                         ),
                          ),
        backgroundColor: wosonPurple,
        iconTheme: const IconThemeData (color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/autoclave_woson.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.12),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF5E2B97),
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionTitle('Informações Gerais'),
                _infoCard(children: [
                  _infoRow(Icons.precision_manufacturing, 'Modelo', cycle.model),
                  _infoRow(Icons.confirmation_number, 'Serial', cycle.serialNumber),
                  _infoRow(Icons.layers, 'Programa', cycle.program),
                  _infoRow(Icons.event, 'Data', _formatDate(cycle.startTime)),
                ]),

                const SizedBox(height: 16),

                _sectionTitle('Parâmetros do Ciclo'),
                _infoCard(children: [
                  _infoRow(Icons.thermostat, 'Temp. Esterilização',
                      '${cycle.sterilizationTemperature} °C'),
                  _infoRow(Icons.timer, 'Tempo Esterilização',
                      '${cycle.sterilizationTime} min'),
                  _infoRow(Icons.air, 'Tempo de Vácuo',
                      '${cycle.vacuumTime} min'),
                  _infoRow(Icons.dry, 'Tempo de Secagem',
                      '${cycle.dryTime} min'),
                ]),

                const SizedBox(height: 16),

                _sectionTitle('Valores Medidos'),
                _infoCard(children: [
                  _infoRow(Icons.device_thermostat,
                      'Temp. Máx. Sensor 1',
                      '${cycle.maxTemperature} °C'),
                  _infoRow(Icons.device_thermostat_outlined,
                      'Temp. Máx. Sensor 2',
                      '${cycle.maxTemperature2} °C'),
                  _infoRow(Icons.speed,
                      'Pressão Máxima',
                      '${cycle.maxPressure} bar'),
                ]),

                const SizedBox(height: 16),

                _sectionTitle('Resultado'),
                _infoCard(children: [
                  _infoRow(
                    cycle.result == 'SUCESSO'
                        ? Icons.check_circle
                        : Icons.error,
                    'Status',
                    cycle.result,
                    valueColor: cycle.result == 'SUCESSO'
                        ? Colors.green
                        : Colors.red,
                  ),
                  if (cycle.errorCode != null)
                    _infoRow(
                      Icons.report_problem,
                      'Código de Erro',
                      cycle.errorCode!,
                      valueColor: Colors.red,
                    ),
                ]),

                // =========================
// DIAGNÓSTICO DE ERRO
// =========================
if (cycle.result != "SUCESSO" && cycle.errorCode != null) ...[
  const SizedBox(height: 16),

  _sectionTitle('Diagnóstico do Erro'),

  _infoCard(children: [

    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Icon(Icons.info, color: Colors.deepPurple),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            _getErrorDescription(cycle.errorCode) ?? "",
            style: const TextStyle(fontSize: 14),
          ),
        ),

      ],
    ),

  ]), 

], 
                const SizedBox(height: 24),

                // ✅ AQUI ESTÁ 
                _sectionTitle('Validação do Laudo'),
                _infoCard(children: [
                  CycleQrWidget(url: cycle.publicUrl),
                ]),

                const SizedBox(height: 24),

                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Gerar PDF do Ciclo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: wosonPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await CyclePdfService.generateCyclePdf(cycle);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDF gerado com sucesso')),
                    );
                  },
                ),

                const SizedBox(height: 32),

                const Opacity(
                  opacity: 0.8,
                  child: Column(
                    children: [
                      Text('Woson · SteriApp',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(
                        'Tecnologia em esterilização odontológica',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Criado por Odontotec Santos · Marcel Nery',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
// BUSCAR DESCRIÇÃO DO ERRO
// =========================
String? _getErrorDescription(String? code) {

  if (code == null) return null;

  // 🔧 garante formato ErXX
  String formattedCode = code;

  if (!formattedCode.toLowerCase().startsWith("er")) {
    formattedCode = "Er${formattedCode.padLeft(2, '0')}";
  }

  try {
    final error = errorCodes.firstWhere(
      (e) => e.code.toLowerCase() == formattedCode.toLowerCase(),
    );

    return error.description;

  } catch (_) {
    return "Erro não encontrado na base de diagnóstico.";
  }
}

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

  Widget _infoCard({required List<Widget> children}) => Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: children),
        ),
      );

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
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
