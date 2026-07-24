import 'package:flutter/material.dart';
import '../../cycles/repositories/cycles_repository.dart';
import '../services/label_counter_service.dart';
import '../../cycles/models/cycle_model.dart'; 
import '../models/label_model.dart';
import '../services/label_pdf_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/auth_service.dart';

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

String clinicName = "";
String operatorName ="";
String dentistName ="";
String autoclaveModel ="";

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

    final serial = Uri.encodeComponent(cycle.serialNumber
    
          .replaceAll("SN.:", "")
          .replaceAll("SN.", "")
          .replaceAll("SN:", "")
          .replaceAll(":", "")
          .trim(),
    
    );


print("--------------------------------");
print("QR GERADO:");
print("https://backend-nu-nine-29.vercel.app/label/$serial/$nextCycle");
print("--------------------------------");
    labels.add(
      LabelModel(
        cycleNumber: nextCycle,
        globalNumber: nextGlobal,
        lotNumber: "$nextCycle-$nextGlobal",
        model: autoclaveModel.isNotEmpty? autoclaveModel: cycle.model,
        serialNumber: cycle.serialNumber,
        program: cycle.program,
        publicUrl: "https://backend-nu-nine-29.vercel.app/label/$serial/$nextCycle",
        responsible: dentistName,
        operator: operatorName,
        clinicName: clinicName,
        sterilizationDate: cycle.startTime,
        validityDate: DateTime(cycle.startTime.year,
                               cycle.startTime.month + 6,
                               cycle.startTime.day,
          )
      ),
    );
  }

  return labels;
}

Future<void> loadUserData() async {

  final token = await AuthService.getToken();

  final response = await http.get(
    Uri.parse(
      "https://backend-nu-nine-29.vercel.app/api/user",
    ),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {

    final data = jsonDecode(response.body);

    final autoclaves = data["autoclaves"] ?? [];

Map<String, dynamic>? selectedAutoclave;

if (widget.lastCycle != null) {

   for (final a in autoclaves) {

  final cadastro =
      (a["serial"] ?? "")
          .toString()
          .replaceAll("SN.:", "")
          .replaceAll("SN.", "")
          .replaceAll("SN:", "")
          .replaceAll(":", "")
          .trim();

  final ciclo =
      widget.lastCycle!.serialNumber
          .replaceAll("SN.:", "")
          .replaceAll("SN.", "")
          .replaceAll("SN:", "")
          .replaceAll(":", "")
          .trim();

  if (cadastro == ciclo) {
    selectedAutoclave = Map<String, dynamic>.from(a);
    break;
  }
}


}

    setState(() {
      clinicName = data["clinic"] ?? "";
      operatorName = data["operator"] ?? "";
      dentistName = data["dentist"] ?? "";
      
      autoclaveModel = selectedAutoclave?["model"]??"";
    });

    print("🏥 CLINICA: $clinicName");
    print("👤 OPERADOR: $operatorName");
    print(" DENTISTA: $dentistName");
  } else {
    print("ERRO AO BUSCAR USUARIO");
  }
}


  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {

    await counter.load();

    await loadUserData();

   lastBleCycle = widget.lastCycle?.cycleNumber ?? 0;

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
  clinicName: clinicName,
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

final model = autoclaveModel.isNotEmpty? autoclaveModel: (lastCycle?.model??"");
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
    "Rastreabilidade",
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
          // CABEÇALHO INSTITUCIONAL               mudanca realizada para o label print ficar mais bonito 23/07
          // ===============================

      

Container(
  height: 320,

  decoration: BoxDecoration(

    borderRadius: BorderRadius.circular(28),

    boxShadow: [

      BoxShadow(

        color: Colors.black.withOpacity(.18),

        blurRadius: 22,

        offset: const Offset(0,10),

      ),

    ],

  ),

  child: ClipRRect(

    borderRadius: BorderRadius.circular(28),

    child: Stack(

      children: [

        //-----------------------------------
        // FOTO DA AUTOCLAVE
        //-----------------------------------

        Positioned.fill(

          child: Image.asset(

            "assets/images/autoclave_woson2.png",

            fit: BoxFit.cover,

          ),

        ),

        //-----------------------------------
        // ESCURECIMENTO
        //-----------------------------------

        Positioned.fill(

          child: Container(

            decoration: BoxDecoration(

              gradient: LinearGradient(

                begin: Alignment.topCenter,

                end: Alignment.bottomCenter,

                colors: [

                  Colors.black.withOpacity(.10),

                  Colors.black.withOpacity(.35),

                  Colors.black.withOpacity(.70),

                ],

              ),

            ),

          ),

        ),

        //-----------------------------------
        // DEGRADÊ ROXO
        //-----------------------------------

        Positioned.fill(

          child: Container(

            decoration: BoxDecoration(

              gradient: LinearGradient(

                begin: Alignment.bottomCenter,

                end: Alignment.topCenter,

                colors: [

                  const Color(0xff5E2B97).withOpacity(.92),

                  const Color(0xff5E2B97).withOpacity(.45),

                  Colors.transparent,

                ],

              ),

            ),

          ),

        ),

        //-----------------------------------
        // CONTEÚDO
        //-----------------------------------

        Padding(

          padding: const EdgeInsets.all(24),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              //--------------------------------

              Row(

                children: [

                  Image.asset(

                    "assets/images/logo_woson.png",

                    height: 42,

                  ),

                  const Spacer(),

                  Container(

                    padding: const EdgeInsets.symmetric(

                      horizontal: 12,

                      vertical: 6,

                    ),

                    decoration: BoxDecoration(

                      color: Colors.green,

                      borderRadius:
                          BorderRadius.circular(30),

                    ),

                    child: const Row(

                      children: [

                        Icon(

                          Icons.check_circle,

                          color: Colors.white,

                          size: 16,

                        ),

                        SizedBox(width:6),

                        Text(

                          "ONLINE",

                          style: TextStyle(

                            color: Colors.white,

                            fontWeight:
                                FontWeight.bold,

                            fontSize:12,

                          ),

                        ),

                      ],

                    ),

                  ),

                ],

              ),

              const Spacer(),

              const Text(

                "CENTRAL DE",

                style: TextStyle(

                  color: Colors.white70,

                  fontSize: 17,

                  letterSpacing: 2,

                ),

              ),

              const SizedBox(height:3),

              const Text(

                "RASTREABILIDADE",

                style: TextStyle(

                  color: Colors.white,

                  fontSize: 30,

                  fontWeight: FontWeight.bold,

                  letterSpacing: 1,

                ),

              ),

              const SizedBox(height:6),

              const Text(

                "STERIAPP",

                style: TextStyle(

                  color: Colors.white,

                  fontSize: 18,

                  fontWeight: FontWeight.w600,

                ),

              ),

              const SizedBox(height:20),

              Container(

                padding: const EdgeInsets.symmetric(

                  horizontal:16,

                  vertical:10,

                ),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(20),

                ),

                child: Row(

                  children: [

                    const Icon(

                      Icons.autorenew,

                      color: Color(0xff5E2B97),

                    ),

                    const SizedBox(width:10),

                    Expanded(

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(

                            "CICLO Nº $nextCycle",

                            style: const TextStyle(

                              fontWeight:
                                  FontWeight.bold,

                              fontSize:18,

                            ),

                          ),

                          const SizedBox(height:2),

                          const Text(

                            "Pronto para rastreabilidade",

                            style: TextStyle(

                              color: Colors.black54,

                            ),

                          ),

                        ],

                      ),

                    ),

                  ],

                ),

              ),

            ],

          ),

        ),

      ],

    ),

  ),

),

          const SizedBox(height: 15),

         
          //==========================================================
          // PAINEL DA AUTOCLAVE
          //==========================================================

Container(

  padding: const EdgeInsets.all(22),

  decoration: BoxDecoration(

    color: Colors.white,

    borderRadius: BorderRadius.circular(24),

    boxShadow: [

      BoxShadow(

        color: Colors.black.withOpacity(.06),

        blurRadius: 18,

        offset: const Offset(0,8),

      ),

    ],

  ),

  child: Column(

    crossAxisAlignment: CrossAxisAlignment.start,

    children: [

      //-------------------------------------------------

      Row(

        children: [

          Container(

            width: 52,

            height: 52,

            decoration: BoxDecoration(

              color: const Color(0xff5E2B97),

              borderRadius: BorderRadius.circular(16),

            ),

            child: const Icon(

              Icons.task_alt_rounded,

              color: Colors.white,

              size: 28,

            ),

          ),

          const SizedBox(width:16),

          const Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(

                  "Autoclave Conectada",

                  style: TextStyle(

                    fontWeight: FontWeight.bold,

                    fontSize:20,

                  ),

                ),

                SizedBox(height:2),

                Text(

                  "Equipamento sincronizado com SteriApp",

                  style: TextStyle(

                    color: Colors.black54,

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

      const SizedBox(height:28),

      _infoTile(

        Icons.category,

        "Modelo",

        model,

      ),

      const Divider(),

      _infoTile(

        Icons.qr_code_2,

        "Número de Série",

        serial,

      ),

      const Divider(),

      _infoTile(

        Icons.person,

        "Operador",

        operatorName,

      ),

      const Divider(),

      _infoTile(

        Icons.medical_services,

        "Responsável",

        dentistName,

      ),

      const Divider(),

      _infoTile(

        Icons.local_hospital,

        "Clínica",

        clinicName,

      ),

    ],

  ),

),
          const SizedBox(height: 15),

          // ===============================
          // ULTIMO CARD 23/07 MODIFICADO
          // ===============================
     

         Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.05),
        blurRadius: 12,
        offset: const Offset(0,5),
      )
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Row(
        children: [

          Icon(
            Icons.dashboard_customize_rounded,
            color: Color(0xff5E2B97),
            size: 30,
          ),

          SizedBox(width:12),

          Text(
            "Central de Rastreabilidade",
            style: TextStyle(
              fontSize:20,
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),

      SizedBox(height:25),

      _actionButton(
        icon: Icons.local_offer_rounded,
        title: "Impressão de Etiquetas",
        subtitle: "Gerar etiquetas de rastreabilidade",
        color: Color(0xff5E2B97),
      ),

      SizedBox(height:15),

      _actionButton(
        icon: Icons.science_outlined,
        title: "Classe 1",
        subtitle: "Indicador químico Classe I",
        color: Colors.deepOrange,
      ),

      SizedBox(height:15),

      _actionButton(
        icon: Icons.biotech,
        title: "Teste Biológico",
        subtitle: "Registro Digital",
        color: Colors.green,
      ),

      SizedBox(height:15),

      _actionButton(
        icon: Icons.history,
        title: "Histórico",
        subtitle: "Consultar ciclos anteriores",
        color: Colors.blue,
      ),

      SizedBox(height:15),

      _actionButton(
        icon: Icons.picture_as_pdf,
        title: "Relatórios PDF",
        subtitle: "Exportar relatórios completos",
        color: Colors.red,
      ),

    ],
  ),
),

          // ===============================
          // BOTÃO DINÂMICO
          // ===============================
          if (total > 0)
          ElevatedButton.icon(
                      onPressed: _confirmDialog,
                      icon: const Icon(
                      Icons.picture_as_pdf,
                                           color: Colors.white,
                                       ),
                      label: Text(
                                   "CRIAR PDF ($total etiquetas)",
                      style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                                ),
                            ),
                   style: ElevatedButton.styleFrom(
                   backgroundColor: wosonPurple,
                   foregroundColor: Colors.white,
                   minimumSize: const Size(double.infinity, 65),
                   shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(18),
                     ),
                  ),
              )
        ],
      ),
    ),
  );
}
}

//======================================================
// INFO TILE
//======================================================

Widget _infoTile(
  IconData icon,
  String title,
  String value,
) {

  return Padding(

    padding: const EdgeInsets.symmetric(
      vertical: 12,
    ),

    child: Row(

      children: [

        Container(

          width: 42,
          height: 42,

          decoration: BoxDecoration(

            color: const Color(0xff5E2B97)
                .withOpacity(.08),

            borderRadius:
                BorderRadius.circular(12),

          ),

          child: Icon(

            icon,

            color: const Color(0xff5E2B97),

          ),

        ),

        const SizedBox(width: 16),

        Expanded(

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(

                title,

                style: const TextStyle(

                  fontSize: 13,

                  color: Colors.black54,

                ),

              ),

              const SizedBox(height: 2),

              Text(

                value.isEmpty ? "-" : value,

                style: const TextStyle(

                  fontWeight: FontWeight.bold,

                  fontSize: 16,

                ),

              ),

            ],

          ),

        ),

      ],

    ),

  );

}

Widget _actionButton({

  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,

}){

 return Material(
  color: Colors.transparent, borderRadius: BorderRadius.circular(18),
  child: InkWell(borderRadius: BorderRadius.circular(18),

splashColor: color.withOpacity(.18),

highlightColor: color.withOpacity(.08),

hoverColor: color.withOpacity(.05),

onTap: () {},

    child: Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: color.withOpacity(.08),

        borderRadius: BorderRadius.circular(18),

      ),

      child: Row(

        children: [

         AnimatedContainer(

  duration: const Duration(milliseconds: 250),

  width: 52,

  height: 52,

  decoration: BoxDecoration(

    color: color,

    borderRadius: BorderRadius.circular(16),

  ),

  child: Icon(

    icon,

    color: Colors.white,

    size: 28,

  ),

),

          const SizedBox(width:18),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  title,

                  style: const TextStyle(

                    fontSize:17,

                    fontWeight: FontWeight.bold,

                  ),

                ),

                const SizedBox(height:4),

                Text(

                  subtitle,

                  style: TextStyle(

                    color: Colors.grey.shade700,

                  ),

                ),

              ],

            ),

          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size:18,
            color: color,
          ),

        ],

      ),

    ),

  ),

  );

}