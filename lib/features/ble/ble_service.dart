import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_constants.dart';
import '../services/autoclave_auth_service.dart';
import '../models/user_model.dart';

class BleService {

// BLE GLOBAL SINGLETON

static final BleService instance = BleService._internal();
factory BleService() => instance;
BleService._internal();

  // =========================
  // VARIÁVEIS BLE
  // =========================
  BluetoothDevice? device;
  BluetoothCharacteristic? characteristic;

  final StreamController<Map<String, dynamic>> _jsonController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get jsonStream => _jsonController.stream;

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<List<int>>? _notifySub;

  bool _isConnecting = false;
  bool _isListening = false;
  bool _frameStarted = false;
  bool _sessionEnabled = false;

  UserModel? currentUser;
  

 // BOTAO APERTADO!

  void enableSession() 
  {
     _sessionEnabled = true;
  }


// =========================
// DETECTAR AUTOCLAVES BLE
// =========================
static Future<List<Map<String,String>>> detectAutoclaves() async {

  List<Map<String,String>> devices = [];

  await FlutterBluePlus.startScan(
    timeout: const Duration(seconds: 4),
    androidUsesFineLocation: true,
  );

  await for (final results in FlutterBluePlus.scanResults) {

    for(final r in results){

      final name = r.device.name;

      if(name == BleConstants.deviceName){

        final serial = r.device.remoteId.str;

        if(!devices.any((d) => d["serial"] == serial)){
          devices.add({
            "model": "Woson Autoclave",
            "serial": serial,
          });
        }

      }

    }

  }

  await FlutterBluePlus.stopScan();

  return devices;

}
 // =========================
  // CONEXÃO BLE
  // =========================



  Future<void> connect() async {
    if (_isConnecting) return;
    _isConnecting = true;

    await FlutterBluePlus.adapterState
        .where((s) => s == BluetoothAdapterState.on)
        .first;

    await FlutterBluePlus.stopScan();

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      androidUsesFineLocation: true,
    );

    final completer = Completer<void>();

    _scanSub = FlutterBluePlus.scanResults.listen((results) async {
      for (final r in results) {
        final name = r.device.name;

        final advServices = r.advertisementData.serviceUuids
            .map((e) => e.str.toUpperCase())
            .toList();

        final foundByName = name == BleConstants.deviceName;
        final foundByService =
            advServices.contains(BleConstants.serviceUUID.toUpperCase());

        if (foundByName || foundByService) {
          device = r.device;

          await FlutterBluePlus.stopScan();
          await _scanSub?.cancel();

          completer.complete();
          break;
        }
      }
    });

    await completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () async {
        await FlutterBluePlus.stopScan();
        await _scanSub?.cancel();
        _isConnecting = false;
        throw Exception('❌ ESP32 não encontrado no scan BLE');
      },
    );
    
    await device!.disconnect().catchError((_){});
    await device!.connect(autoConnect: false);
    await device!.requestMtu(247);

    final services = await device!.discoverServices();

    for (final service in services) {
      if (service.uuid.str.toUpperCase() ==
          BleConstants.serviceUUID.toUpperCase()) {
        for (final c in service.characteristics) {
          if (c.uuid.str.toUpperCase() ==
              BleConstants.characteristicUUID.toUpperCase()) {
            characteristic = c;

            _listenConnectionState();
            _isConnecting = false;
            return;
          }
        }
      }
    }

    _isConnecting = false;
    throw Exception('❌ Characteristic BLE não encontrada');
  }

  // =========================
  // ATIVAR RECEBIMENTO
  // =========================
  Future<void> startListening() async {
  if (characteristic == null || _isListening) return;

  _isListening = true;

  await characteristic!.setNotifyValue(true);

  // ==========================
  // HANDSHAKE PROFISSIONAL BLE
  // ==========================
  await characteristic!.write(
    utf8.encode("START"),
    withoutResponse: false,
  );

  print('🤝 Handshake START enviado');

  _jsonBuffer.clear();
  _packetQueue.clear();

  _notifySub = characteristic!.value.listen(
    _onDataReceived,
    onError: (e) {
      print('❌ Erro no stream BLE: $e');
    },
    onDone: () {
      _isListening = false;
    },
  );

  print('🟢 BLE pronto para receber chunks');
  _jsonController.add({
    "__event": "connected"
  });
}
// =========================
// RECEIVER PROFISSIONAL
// =========================

final StringBuffer _jsonBuffer = StringBuffer();

final List<String> _packetQueue = [];

int _braceCount = 0;
bool _jsonStarted = false;

bool _assembling = false;
Timer? _timeoutTimer;

static const Duration jsonTimeout = Duration(seconds: 2);
  // =========================
  // RECEBER CHUNKS
  // =========================
void _onDataReceived(List<int> data) {

  String chunk = utf8.decode(data, allowMalformed: true);

  print("📦 RAW CHUNK: $chunk");

  /* ================= START FRAME ================= */

  if (chunk.contains("<START>")) {

    print("🚀 FRAME START");

    _frameStarted = true;

    _jsonBuffer.clear();
    _packetQueue.clear();

    _braceCount = 0;
    _jsonStarted = false;

    // remove marcador do pacote
    chunk = chunk.replaceAll("<START>", "");
  }

  /* ================= IGNORA SE NÃO INICIOU ================= */

  if (!_frameStarted) return;

  /* ================= END FRAME ================= */

  

if (chunk.contains("<END>")) {

  print("✅ FRAME END");

  chunk = chunk.replaceAll("<END>","");

  if (chunk.isNotEmpty){_packetQueue.add(chunk);}

 
  _processQueue(); // termina de consumir fila

  _finalizeJson(); // ⭐ FINALIZA AQUI
   _frameStarted = false;

  return;
}
  /* ================= CHUNK NORMAL ================= */

  if (chunk.isNotEmpty) {
    _packetQueue.add(chunk);
  }

  _processQueue();
}


void _processQueue() {

  if (_assembling) return;
  _assembling = true;

  while (_packetQueue.isNotEmpty) {

    final chunk = _packetQueue.removeAt(0);

    for (int i = 0; i < chunk.length; i++) {

      final char = chunk[i];

      if (char == '{') {
        _braceCount++;
        _jsonStarted = true;
      }

      if (_jsonStarted) {
        _jsonBuffer.write(char);
      }

      if (char == '}') {
        _braceCount--;
      }
    }

    _restartTimeout();
  }

  _assembling = false;
}

void _restartTimeout() {

  _timeoutTimer?.cancel();

  _timeoutTimer = Timer(jsonTimeout, () {
    print("⚠️ Timeout JSON — buffer limpo");
    _jsonBuffer.clear();
  });
}

void _finalizeJson() {

  final fullJson = _jsonBuffer.toString();

  _jsonBuffer.clear();
  _timeoutTimer?.cancel();

  _braceCount = 0;
  _jsonStarted = false;

  print("📦 JSON recebido (${fullJson.length} bytes)");

  try {

    final decoded =
        jsonDecode(fullJson) as Map<String, dynamic>;

    print("✅ JSON válido");

      // =========================
    // AUTORIZAÇÃO DA AUTOCLAVE
    // =========================

    final serial = decoded["serial"];

    if(currentUser != null && serial != null){

      final authorized =
          AutoclaveAuthService.isAutoclaveAuthorized(
            currentUser!,
            serial,
          );

      if(!authorized){
        print("⛔ Autoclave NÃO autorizada: $serial");
        return;
      }

      print("🔐 Autoclave autorizada: $serial");

    }

    // envia JSON para o app
    _jsonController.add(decoded);

  } catch (e) {

    print("❌ JSON inválido descartado: $e");
  }
}


// AUTENTICAÇÃO PARA LIBERAR OS CICLOS 16/03 SERIAL NUMBER 

void setUser(UserModel user){
  currentUser = user;
}



// =========================
// AUTO RECONNECT BLE
// =========================
void _listenConnectionState() {

  device?.connectionState.listen((state) async {

    print("BLE STATE: $state");

    if (state == BluetoothConnectionState.disconnected && _sessionEnabled) {

      print("🔴 BLE desconectado detectado");

      try {
        // 🔥 1️⃣ Cancela notify
        await _notifySub?.cancel();
        _notifySub = null;

        // 🔥 2️⃣ Força limpar conexão Android
        await device?.disconnect();

      } catch (_) {}

      // 🔥 3️⃣ Limpa variáveis
      characteristic = null;
      device = null;
      _isListening = false;

      // 🔥 4️⃣ Notifica UI
      _jsonController.add({
        "__event": "disconnected"
      });

      print("🧹 Stack BLE limpa");

      // 🔥 5️⃣ Pequeno delay para ESP voltar a anunciar
      await Future.delayed(const Duration(seconds: 2));

      print("🔁 Tentando reconectar...");

      try {
        await connect();
        await startListening();
      } catch (e) {
        print("❌ Falha reconexão: $e");
      }
    }
  });
}

  // =========================
  // DISCONNECT
  // =========================
  Future<void> disconnect() async {
    await _scanSub?.cancel();
    await _notifySub?.cancel();
    await device?.disconnect();
    device = null;
    _isListening = false;
  }

  void dispose() {
    _scanSub?.cancel();
    _notifySub?.cancel();
    _jsonController.close();
  }
}