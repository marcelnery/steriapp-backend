// VERSÃO ATUALIZADA 13/07 STERIAPP COM LAYOUT MAIS ATRATIVO PARA DUAS OU TRES AUTOCLAVES


import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../labels/pages/label_print_page.dart';
import '../../labels/pages/label_splash_page.dart';
import '../models/cycle_model.dart';
import '../repositories/cycles_repository.dart';
import '../../ble/ble_service.dart';
import 'cycle_detail_page.dart';
import '../../errors/services/error_report_service.dart';


class CyclesPage extends StatefulWidget {
  const CyclesPage({super.key});

  @override
  State<CyclesPage> createState() => _CyclesPageState();
}

class _CyclesPageState extends State<CyclesPage> {
  final CyclesRepository repository = CyclesRepository.instance;
  final ScrollController _scrollController = ScrollController();
  final BleService ble = BleService.instance;

  List<CycleModel> cycles = [];
  bool loading = false;
  bool loadingMore = false;
  String? error;

  int currentPage = 1;
  final int limit = 10;
  bool hasMore = true;

  StreamSubscription? _bleSubscription;
  bool bleListening = false;
  bool bleConnecting = false;
  bool bleConnected = false; // NOVO: indicador visual BLE

  // FUNCAO SUBSTITUIDA String? registeredSerial; // NOVA FUNCAO PARA COMPARAR O SERIAL RECEBIDO E O SERIAL TRANSMITIDO 07/05/2026
  final Set<String> registeredSerials = {}; // funcao trocada para fazer funcionar 2 e ate 3 autoclaves para transmissao 25/06
  final Map<String, String> registeredModels = {};
 // =====================================
 // FILTRO DE AUTOCLAVES                     NOVA FUNCAO PARA CRIAR BOTAO DE SEPARACAO DE CICLOS, QUANDO 2 OU MAIS AUTOCLAVES 13/07
 // ===================================== 
 
List<Map<String, dynamic>> userAutoclaves = [];
String selectedSerial = "ALL";

@override
void initState() {
  super.initState();

  loadRegisteredSerial();

  _loadFirstPage();

  _scrollController.addListener(_onScroll);
}
// ====================================================
// NOVA ACAO PARA O SERIAL SER REGISTRADO E ANALISADO     antiga funcao 1 autoclave
// ====================================================
/*
Future<void> loadRegisteredSerial() async {
  try {

    final user = await repository.getLoggedUser();

    final serial =
        user['autoclaves'][0]['serial']
            .toString();

    registeredSerial = serial
        .replaceAll(' ', '')
        .trim()
        .toUpperCase();

    debugPrint('🔐 SERIAL REGISTRADO: $registeredSerial');

  } catch (e) {

    debugPrint('❌ Erro carregando serial');
    debugPrint(e.toString());
  }
}
*/

// ========================================
// NOVA FUNCAO PARA 2 E ATE 3 ATUOCLAVES
// ========================================

Future<void> loadRegisteredSerial() async {
  try {

    final user = await repository.getLoggedUser();

    registeredSerials.clear();
    registeredModels.clear();

    final autoclaves = user['autoclaves'] ?? [];

    userAutoclaves = List<Map<String, dynamic>>.from(autoclaves);

    // Segurança: nunca permitir mais que 3
    for (int i = 0; i < autoclaves.length && i < 3; i++) {

      final serial = autoclaves[i]['serial']
          .toString()
          .replaceAll(' ', '')
          .trim()
          .toUpperCase();

        final model =

      autoclaves[i]['model']

          .toString()

          .trim();

       registeredSerials.add(serial);

       registeredModels[serial] = model;

    
    }

         debugPrint("🔐 AUTOCLAVES:");

         registeredModels.forEach((serial, model) {

         debugPrint("$model -> $serial");

        });
    
      if(mounted) {
        setState((){});
      }
  } catch (e) {

    debugPrint("❌ Erro carregando autoclaves");
    debugPrint(e.toString());

  }
}


  // =========================
  // PERMISSÕES BLE
  // =========================
  Future<void> _requestBlePermissions() async {
    debugPrint('🔐 Solicitando permissões BLE');

    if (Platform.isAndroid) {
      await [
        Permission.locationWhenInUse,
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
    }

    if (Platform.isIOS) {
      await [Permission.bluetooth].request();
    }

    debugPrint('✅ Permissões BLE OK');
  }

  // =========================
  // CONECTAR + ESCUTAR BLE
  // =========================
  Future<void> _connectAndListenBle() async {

  // ✅ CONTINUA EXISTINDO (proteção)
  if (bleListening || bleConnecting) {
    debugPrint('⚠️ BLE já ativo ou conectando');
    return;
  }

  setState(() {
    bleConnecting = true;
  });

  try {
    debugPrint('🚀 INICIANDO FLUXO BLE');

    await _requestBlePermissions();

    ble.enableSession(); // USUARIO AUTORIZOU BLE

    debugPrint('🔌 Conectando ao dispositivo BLE...');

    await ble.connect();

   
    // ===============================
    // ⭐ LISTENER BLE
    // ===============================

    await _bleSubscription?.cancel();

    _bleSubscription = ble.jsonStream.listen(
      (json) async {

      if (json["__event"] != null) {

  if (json["__event"] == "connected") {
    debugPrint("🟢 Evento BLE: conectado");

    if (mounted) {
      setState(() {
        bleConnected = true;
        bleListening = true;
      });
    }
    return;
  }

  if (json["__event"] == "disconnected") {
    debugPrint("🔴 Evento BLE: desconectado");

    if (mounted) {
      setState(() {
        bleConnected = false;
        bleListening = false;
      });
    }
    return;
  }
}
        try {
          debugPrint('📡 JSON RECEBIDO VIA BLE');
          debugPrint(json.toString());

  //        final cycle = repository.addFromBleJson(json);  alterando com seguranca a transmissao ble 07/05/2026
//          aqui fazemos a conferencia de quando chega o ciclo de ble se tem o numero de serie no ciclo e vai ser 
//          comparado com o do cadastro para se for igual passa pra frente e se nao for nao passa

// ===============================
// SERIAL RECEBIDO DA ESP32 de BLE
// ===============================

final incomingSerial =
    (json['serial'] ?? '')
        .toString()
        .replaceAll(':', '')
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .trim()
        .toUpperCase();

// debugPrint('📡 SERIAL RECEBIDO: $incomingSerial'); antiga funcao para 1 autoclave

// debugPrint('🔐 SERIAL REGISTRADO: $registeredSerial'); antiga funcao para 1 autoclave

debugPrint('📡 SERIAL RECEBIDO: $incomingSerial'); // nova funcao para 2 ate 3 autoclave debug 25/06/2026

debugPrint('🔐 AUTOCLAVES CADASTRADAS:');
for (final serial in registeredSerials) {
  debugPrint(serial);
}

// ===============================
// VALIDAÇÃO DE SEGURANÇA
// ===============================
/*
if (registeredSerial == null ||
    registeredSerial!.isEmpty) {

  debugPrint('❌ Usuário sem serial cadastrado');

  return;
}

// ===============================
// BLOQUEIO DE AUTOCLAVE ERRADA
// ===============================

if (incomingSerial != registeredSerial) {

  debugPrint('🚫 AUTOCLAVE NÃO AUTORIZADA');
  debugPrint('🚫 Ciclo IGNORADO');

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'AUTOCLAVE NÃO CADASTRADA OU CICLO SEM SN IGNORADO',
        ),
      ),
    );
  }

  return;
}

*/  
// FUNCAO ANTIGA SUBSTITUIDA POR ABAIXO 25/06/2026


if (registeredSerials.isEmpty) {

  debugPrint("❌ Nenhuma autoclave cadastrada");

  return;
}

// ===============================
// BLOQUEIO DE AUTOCLAVE ERRADA
// ===============================

if (!registeredSerials.contains(incomingSerial)) {

  debugPrint("🚫 AUTOCLAVE NÃO AUTORIZADA");
  debugPrint("🚫 Ciclo IGNORADO");

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "AUTOCLAVE NÃO CADASTRADA",
        ),
      ),
    );
  }

  return;
}

// ===============================
// SERIAL AUTORIZADO
// ===============================

debugPrint('✅ SERIAL AUTORIZADO');

final cycle = repository.addFromBleJson(json);


          if (cycle != null && cycle.errorCode != null) {
  await ErrorReportService.prepareFactoryReport(cycle);
       }

           if (mounted) {
              setState(() {
                cycles = repository.getAllCycles();
              });
            }
           if(cycle !=null){
            repository.sendToBackend(cycle)
              .then((_) {
                debugPrint('☁️ Ciclo enviado ao backend');
              })
              .catchError((_) {
                debugPrint('⚠️ Backend offline — salvo local');
              });
          }

        } catch (e, s) {
          debugPrint('❌ Erro processamento BLE');
          debugPrint(e.toString());
          debugPrint(s.toString());
        }
      },

      onError: (e) {
        debugPrint('❌ Erro no stream BLE: $e');
      },

      onDone: () {
        debugPrint('🔌 Stream BLE encerrado');

        if (mounted) {
          setState(() {
            bleConnected = false;
            bleListening = false;
          });
        }
      },
    );

    debugPrint('🎧 Iniciando escuta BLE...');
    await ble.startListening();

    // ✅ CONTINUA EXISTINDO
    setState(() {
      bleListening = true;
    });

    debugPrint('✅ BLE conectado e escutando');

  } catch (e, s) {
    debugPrint('❌ Falha no fluxo BLE');
    debugPrint(e.toString());
    debugPrint(s.toString());

    setState(() {
      bleConnected = false;
    });

  } finally {
    setState(() {
      bleConnecting = false;
    });
  }
}
  @override
  void dispose() {
    debugPrint('🛑 Encerrando CyclesPage');
    _bleSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // =========================
  // PAGINAÇÃO
  // =========================
  Future<void> _loadFirstPage() async {
    setState(() {
      loading = true;
      error = null;
      currentPage = 1;
      hasMore = true;
    });

    try {
      final result = await repository.fetchCycles(
        page: 1,
        limit: limit,
        clearBefore: true,
      );

      setState(() {
        cycles = repository.getAllCycles();
        hasMore = result.length == limit;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (loadingMore || !hasMore) return;

    setState(() {
      loadingMore = true;
    });

    try {
      final nextPage = currentPage + 1;

      final result = await repository.fetchCycles(
        page: nextPage,
        limit: limit,
      );

      setState(() {
        currentPage = nextPage;
        cycles = repository.getAllCycles();
        hasMore = result.length == limit;
      });
    } finally {
      setState(() {
        loadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadNextPage();
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    const wosonPurple = Color(0xFF5E2B97);
  final displayedCycles = selectedSerial == "ALL"
    ? cycles
    : cycles.where((c) {

        final cycleSerial = c.serialNumber
            .replaceAll(':', '')
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .trim()
            .toUpperCase();

        final selected = selectedSerial
            .replaceAll(':', '')
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .trim()
            .toUpperCase();

                print("Filtro = $selected");
                print("Ciclo  = $cycleSerial");

        return cycleSerial == selected;
    

      }).toList();

String pageTitle = "Ciclos de Esterilização";

if (selectedSerial != "ALL") {

  final serials = registeredSerials.toList();

  final index = serials.indexOf(selectedSerial);

  final model = registeredModels[selectedSerial] ?? "Autoclave";

  if (index >= 0) {
    pageTitle = "$model ${index + 1}";
  }

}
    return Scaffold(
   appBar: AppBar(
  title: Text(
  pageTitle,
  style: const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
),
  backgroundColor: wosonPurple,
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  actions: [
    TextButton.icon(
      onPressed: () {
CycleModel? cycleToPrint;

// ===============================
// TODAS AS AUTOCLAVES
// ===============================

if (selectedSerial == "ALL") {

  cycleToPrint = repository.getLatestCycle();

}

// ===============================
// AUTOCLAVE SELECIONADA
// ===============================

else {

  cycleToPrint =
      repository.getLatestCycleBySerial(
        selectedSerial,
      );

}

print("=========================");
print("CICLO PARA IMPRESSÃO");
print(cycleToPrint?.model);
print(cycleToPrint?.serialNumber);
print(cycleToPrint?.program);
print("=========================");

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => LabelSplashPage(
      lastCycle: cycleToPrint,
    ),
  ),
);
      },
      icon: const Icon(Icons.print, color: Colors.white),
      label: const Text(
        "Imprimir\nETIQUETA🏷️",
        style: TextStyle(color: Colors.white),
      ),
    ),
  ],
),

      body: Column(
        children: [
          const SizedBox(height: 16),

          // =========================
          // BOTÃO CONECTAR + INDICADOR BLE
          // =========================
    Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: SizedBox(
    width: double.infinity,
    height: 80,
    child: ElevatedButton.icon(

      // 🔥 nunca deixar null (senão fica apagado)
      onPressed: bleConnecting ? null : _connectAndListenBle,

      // =========================
      // ÍCONE
      // =========================
      icon: Icon(
        bleConnected
            ? Icons.check_circle
            : bleConnecting
                ? Icons.sync
                : Icons.bluetooth,
        size: 30,
        color: bleConnected ? Colors.green : Colors.white,
      ),

      // =========================
      // TEXTO
      // =========================
      label: Text(
        bleConnected
            ? 'Conectado'
            : bleConnecting
                ? 'Conectando...'
                : 'Conectar',

        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),

      // =========================
      // ESTILO
      // =========================
      style: ElevatedButton.styleFrom(
        backgroundColor: wosonPurple, // 🔥 sempre roxo
        disabledBackgroundColor:
            wosonPurple, // 🔥 impede ficar cinza
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
  ),
),
const SizedBox(height: 12),

// ======================================
// FILTRO DE AUTOCLAVES (2 OU 3)
// ======================================

if (userAutoclaves.length > 1)

  SizedBox(
    height: 46,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [

        // BOTÃO TODAS
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: const Text("Todas"),
            selected: selectedSerial == "ALL",
            onSelected: (_) {

              setState(() {
                selectedSerial = "ALL";
              });

            },
          ),
        ),

        // AUTOCLAVES
        ...List.generate(userAutoclaves.length, (index) {

          final autoclave = userAutoclaves[index];

          final serial = autoclave["serial"]
              .toString()
              .replaceAll(" ", "")
              .trim()
              .toUpperCase();

          final model = autoclave["model"] ?? "Autoclave";

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(

              label: Text(
                "$model ${index + 1}",
              ),

              selected: selectedSerial == serial,

              onSelected: (_) {

                setState(() {

                  selectedSerial = serial;

                });

              },
            ),
          );

        }),

      ],
    ),
  ),

const SizedBox(height: 12),
// =========================
// FILTRO DOS CICLOS          funcao criada para usuario com mais do que 1 autoclave 13/07
// =========================



          // =========================
          // LISTA DE CICLOS     OS CARDS BONITOS QUE APARECEM A CADA NOVO CICLO
          // =========================
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: displayedCycles.length + (loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= displayedCycles.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final c = displayedCycles[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.autorenew_rounded,
                        color: wosonPurple),


        title: Row(
  children: [

    Text(
      "Ciclo #${c.cycleNumber}",
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),

    const SizedBox(width: 10),

    const Text(
      "Modelo ",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),

    Text(c.model),
  ],
),

subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    const SizedBox(height: 6),

    Row(
      children: [

        const Text(
          "Programa ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        Text(c.program),

        const Spacer(),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: c.result == 'SUCESSO'
                ? Colors.green.withOpacity(0.15)
                : Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            c.result == "SUCESSO" ? "SUCCESS" : "ERROR",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: c.result == 'SUCESSO'
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ),
      ],
    ),

    const SizedBox(height: 6),

    const Text(
      "Data",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),

    Text(
      "${c.startTime.year}-${c.startTime.month.toString().padLeft(2,'0')}-${c.startTime.day.toString().padLeft(2,'0')}",
    ),

    Text(
      "${c.startTime.hour.toString().padLeft(2,'0')}:${c.startTime.minute.toString().padLeft(2,'0')}:${c.startTime.second.toString().padLeft(2,'0')}",
    ),
  ],
),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CycleDetailPage(cycle: c),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


