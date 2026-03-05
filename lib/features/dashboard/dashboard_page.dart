import 'package:flutter/material.dart';
import '../cycles/pages/cycles_page.dart'; // ✅ Importa CyclesPage
import '../errors/pages/error_parameters_page.dart';

/// =========================
/// DASHBOARD PRINCIPAL
/// =========================
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    const wosonPurple = Color(0xFF4A148C);

    return Scaffold(
     appBar: AppBar(
  backgroundColor: wosonPurple,
  elevation: 0,

  title: const Text(
    'Pagina Inicial · SteriApp',
    style: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  iconTheme: const IconThemeData(
    color: Colors.white, // seta voltar branca
  ),
),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF3E5F5),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),



        child: Column(
          children: [
            const SizedBox(height: 32),

            // =========================
            // BOTÃO ABRIR CICLOS (BLE + Backend)
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CyclesPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.autorenew),
                  label: const Text('Ciclos de Esterilização'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: wosonPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // BOTÕES FUTUROS (Configurações / Status)
            // =========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: abrir configurações
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Configurações'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: wosonPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
               onPressed: () {
               Navigator.of(context).push(
                 MaterialPageRoute(
                 builder: (_) => const ErrorParametersPage(),
                                   ),
                                );
                            },
                  icon: const Icon(Icons.info),
                  label: const Text('Parâmetros de Erros'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: wosonPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            Expanded(
              child: Center(
                child: Text(
                  'Bem-vindo ao SteriApp!\nClique em "Ciclos de Esterilização" para iniciar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}