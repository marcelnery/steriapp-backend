import 'package:flutter/material.dart';
import '../../cycles/repositories/cycles_repository.dart';
import '../services/label_counter_service.dart';
import '../../cycles/models/cycle_model.dart'; 
import '../models/label_model.dart';
import '../services/label_pdf_service.dart';

class LabelPrintPage extends StatefulWidget {

  final CycleModel? lastCycle;

  const LabelPrintPage({
    super.key,
    required this.lastCycle,
  });

  @override
  State<LabelPrintPage> createState() => _LabelPrintPageState();
}

class _LabelPrintPageState extends State<LabelPrintPage> {

  final counter = LabelCounterService.instance;
  final repository = CyclesRepository.instance;

  final TextEditingController qtyGController = TextEditingController();
  final TextEditingController qtyMController = TextEditingController();

  int nextCycle = 0;
  int lastBleCycle = 0;

  List<LabelModel> _generateLabels({
  required CycleModel cycle,
  required int quantity,
}) {

  final List<LabelModel> labels = [];

  int nextGlobal = counter.lastGlobalNumber;

  for (int i = 0; i < quantity; i++) {

    nextGlobal++;

    labels.add(
      LabelModel(
        cycleNumber: cycle.cycleNumber,
        globalNumber: nextGlobal,
        lotNumber: "${cycle.cycleNumber}-$nextGlobal",
        model: cycle.model,
        serialNumber: cycle.serialNumber,
        program: cycle.program,
        publicUrl: cycle.publicUrl,
        responsible: "Responsável Técnico",
        sterilizationDate: cycle.startTime,
        validityDate: cycle.startTime.add(const Duration(days: 7)),
      ),
    );
  }

  return labels;
}

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {

    await counter.load();

    final lastCycleObj = repository.getLastCycle();
    lastBleCycle = lastCycleObj?.cycleNumber ?? 0;

    nextCycle = counter.getNextCycle(lastBleCycle);

    setState(() {});
  }

  void _confirmDialog() {

    final qtyG = int.tryParse(qtyGController.text) ?? 0;
    final qtyM = int.tryParse(qtyMController.text) ?? 0;

    final total = qtyG + qtyM;

    if (total == 0) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar impressão"),
        content: const Text(
          "Você tem certeza que deseja criar as etiquetas?\n\n"
          "Uma vez criada, a numeração rastreada não poderá ser alterada."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("NÃO"),
          ),
          ElevatedButton(
      onPressed: () async {

  final lastCycle = widget.lastCycle;
  if (lastCycle == null) return;

  final qtyG = int.tryParse(qtyGController.text) ?? 0;
  final qtyM = int.tryParse(qtyMController.text) ?? 0;
  final total = qtyG + qtyM;

  if (total == 0) return;

  // 🔹 Primeiro gera as labels
  final labels = _generateLabels(
    cycle: lastCycle,
    quantity: total,
  );

  print("Etiquetas geradas: ${labels.length}");
await LabelPdfService.generatePdf(
  labels: labels,
  clinicName: "NOME DA CLÍNICA",
);

  // 🔹 Depois confirma contador
  await counter.confirmPrint(
    printedCycle: nextCycle,
    quantity: total,
  );

  Navigator.pop(context);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Etiquetas registradas com sucesso"),
    ),
  );

  setState(() {
    nextCycle = counter.getNextCycle(lastBleCycle);
  });
},
            child: const Text("SIM"),
          )
        ],
      ),
    );
  }

  @override
Widget build(BuildContext context)
 {

final lastCycle = widget.lastCycle;

final model = lastCycle?.model ?? "";
final serial = lastCycle?.serialNumber ?? "";
final program = lastCycle?.program ?? "";


  const wosonPurple = Color(0xFF5E2B97);

  final qtyG = int.tryParse(qtyGController.text) ?? 0;
  final qtyM = int.tryParse(qtyMController.text) ?? 0;
  final total = qtyG + qtyM;

  return Scaffold(
    backgroundColor: Colors.grey.shade100,
 appBar: AppBar(
  backgroundColor: wosonPurple,
  iconTheme: const IconThemeData(color: Colors.white),
  title: const Text(
    "Impressão de Etiquetas",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ===============================
          // CABEÇALHO INSTITUCIONAL
          // ===============================
       Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
      )
    ],
  ),
  child: Column(
    children: [

      Image.asset(
        "assets/images/logo_woson.png",
        height: 160,
      ),

      const SizedBox(height: 15),

      const Text(
        "Rastreabilidade é aqui!",
        style: TextStyle(fontSize: 16),
      ),

      const SizedBox(height: 4),

      const Text(
        "APP STERIAPP",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 4),

      const Text(
        "Confiança que traduz Esterilização",
        textAlign: TextAlign.center,
      ),
    ],
  ),
),
          const SizedBox(height: 25),

          // ===============================
          // INFORMAÇÕES DO CICLO
          // ===============================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Informações da Autoclave",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
               Text(
                     "Modelo:",
                style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                Text("$model"),

                   SizedBox(height: 8),

                     Text(
                           "Nº Série:",
                       style: TextStyle(fontWeight: FontWeight.bold),
                           ),
                     Text("$serial"),

                        SizedBox(height: 8),

                           Text(
                                "Programa:",
                           style: TextStyle(fontWeight: FontWeight.bold),
                               ),
                Text("$program"),
                Text(
                  "Próximo Ciclo: $nextCycle",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: wosonPurple,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ===============================
          // QUANTIDADES
          // ===============================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              children: [

                const Text(
                  "Quantidade de Etiquetas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: qtyGController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: "Etiqueta 100x100 (G)",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: qtyMController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: "Etiqueta 100x50 (M)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ===============================
          // BOTÃO DINÂMICO
          // ===============================
          if (total > 0)
            ElevatedButton(
              onPressed: _confirmDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: wosonPurple,
                minimumSize: const Size(double.infinity, 65),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                "CRIAR PDF ($total etiquetas)",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
}