import 'package:flutter/material.dart';
import '../controllers/cycles_controller.dart';
import '../repositories/cycles_repository.dart';
import '../models/cycle_model.dart';

/// Página que exibe todos os ciclos registrados
/// em uma lista, com informações completas.
class CyclesListPage extends StatefulWidget {
  const CyclesListPage({super.key});

  @override
  State<CyclesListPage> createState() => _CyclesListPageState();
}

class _CyclesListPageState extends State<CyclesListPage> {
  late final CyclesController controller;

  @override
  void initState() {
    super.initState();
    controller = CyclesController(CyclesRepository());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Ciclos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Limpar histórico',
            onPressed: () {
              controller.clearHistory();
            },
          )
        ],
      ),
      body: ValueListenableBuilder<List<CycleModel>>(
        valueListenable: controller.cyclesNotifier,
        builder: (context, cycles, _) {
          if (cycles.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum ciclo registrado ainda',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cycles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cycle = cycles[index];

              return Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Número do ciclo (mostrando do mais recente para o antigo)
                      Text(
                        'Ciclo ${cycles.length - index}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Informações detalhadas do ciclo
                      _infoRow('Início', _formatDate(cycle.startTime)),
                      _infoRow('Fim', _formatDate(cycle.endTime)),
                      _infoRow(
                        'Temperatura',
                        '${cycle.maxTemperature.toStringAsFixed(1)} °C',
                      ),
                      _infoRow(
                        'Pressão',
                        '${cycle.maxPressure.toStringAsFixed(2)} bar',
                      ),
                      _infoRow('Status', cycle.result.toUpperCase()),
                      _infoRow('Programa', cycle.program),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Widget auxiliar para criar uma linha com label e valor
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Formata a data para "dd/MM/yyyy HH:mm"
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
  