// CADASTRO DO USUARIO CLINICA E AUTOCLAVE

/*

AQUI CRIAMOS UMA DETECÇÃO DE ATÉ NO MAXIMO 3 AUTOCLAVES
CADASTRA E ENVIA PARA BAKCEND
*/
import 'package:flutter/material.dart';
import '../ble/ble_service.dart';
import 'auth_service.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  // =========================
  // CLÍNICA
  // =========================
  final clinicController = TextEditingController();
  final cnpjController = TextEditingController();
  final streetController = TextEditingController();
  final districtController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final phoneController = TextEditingController();

  // =========================
  // RESPONSÁVEL
  // =========================
  final dentistController = TextEditingController();
  final croController = TextEditingController();
  final userController = TextEditingController();
  final emailController = TextEditingController();

  //===========================
  // PASSWORD CONTROLE
  //===========================

  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();



  List<Map<String,String>> autoclaves = [];
  bool scanning = false;
  bool loading = false;

  // =========================
  // DETECÇÃO BLE
  // =========================
  Future<void> detectAutoclaves() async {

    setState(() {
      scanning = true;
      autoclaves = [];
    });

    try {
      final devices = await BleService.detectAutoclaves()
          .timeout(const Duration(seconds: 15));

      if(devices.isEmpty){
        _showManualOption();
      } else {
        setState(() {
          autoclaves = devices.take(3).toList();
        });
      }

    } catch (e) {
      print("Erro BLE: $e");
      _showManualOption();
    }

    setState(() => scanning = false);
  }

  void _showManualOption(){
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Autoclave não encontrada"),
        content: const Text(
          "Não foi possível detectar autoclaves próximas.\n\nDeseja cadastrar manualmente?"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addManualAutoclave();
            },
            child: const Text("Cadastrar Manualmente"),
          )
        ],
      ),
    );
  }

  void _addManualAutoclave(){

    final modelController = TextEditingController();
    final serialController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cadastrar Autoclave"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: modelController,
              decoration: const InputDecoration(labelText: "Modelo"),
            ),
            TextField(
              controller: serialController,
              decoration: const InputDecoration(labelText: "Número de Série"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {

              if(serialController.text.isEmpty || modelController.text.isEmpty){
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Preencha modelo e serial"))
  );
  return;
}

              if(autoclaves.length >= 3){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Máximo de 3 autoclaves"))
                );
                return;
              }

              setState(() {
                autoclaves.add({
                  "model": modelController.text.isEmpty ? "Woson" : modelController.text,
                  "serial": serialController.text,
                });
              });

              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  Widget buildAutoclaves(){

    if(autoclaves.isEmpty){
      return const Text("Nenhuma autoclave cadastrada");
    }

    return Column(
      children: autoclaves.map((auto){
        return Card(
          child: ListTile(
            leading: const Icon(Icons.medical_services),
            title: Text(auto["model"] ?? ""),
            subtitle: Text("Serial: ${auto["serial"]}"),
          ),
        );
      }).toList(),
    );
  }

  // =========================
  // CADASTRO FINAL
  // =========================
 Future<void> submit() async {

  setState(() => loading = true);

  // =========================
  // DEBUG 1 - AUTOCALVES BRUTO
  // =========================
  print("===== DADOS DE AUTOCLAVES (BRUTO) =====");
  print(autoclaves);

  // =========================
  // MONTAR JSON CORRETO
  // =========================
  final body = {
    "email": emailController.text,
    "nickname": nicknameController.text,
    "password": passwordController.text,
    "clinic": clinicController.text,
    "cnpj": cnpjController.text,
    "address": {
      "street": streetController.text,
      "district": districtController.text,
      "city": cityController.text,
      "state": stateController.text,
    },
    "phone": phoneController.text,
    "dentist": dentistController.text,
    "cro": croController.text,
    "autoclaves": autoclaves.map((a) => {
      "brand": "Woson",
      "model": a["model"].toString(),
      "serial": a["serial"].toString(),
    }).toList(),
  };

  // =========================
  // DEBUG 2 - JSON FINAL
  // =========================
  print("===== JSON FINAL ENVIADO =====");
  print(jsonEncode(body));

  // =========================
  // ENVIO PARA BACKEND
  // =========================
final success = await AuthService.register(
  nickname: body["nickname"] as String,
  email: body["email"] as String,
  password: body["password"] as String,
  clinic: body["clinic"] as String,
  cnpj: body["cnpj"] as String,

  address: Map<String, String>.from(body["address"]as Map),

  phone: body["phone"] as String,
  dentist: body["dentist"] as String,
  cro: body["cro"] as String,

  autoclaves: (body["autoclaves"] as List)
      .map((e) => Map<String, dynamic>.from(e))
      .toList(),
);
  setState(() => loading = false);

  // =========================
  // RESULTADO
  // =========================
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cadastro realizado com sucesso"))
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Erro ao cadastrar"))
    );
  }
}
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text("Cadastro SteriApp")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("Dados da Clínica", style: TextStyle(fontSize:18,fontWeight:FontWeight.bold)),

            TextField(controller: clinicController, decoration: const InputDecoration(labelText: "Nome da clínica")),
            TextField(controller: cnpjController, decoration: const InputDecoration(labelText: "CNPJ / CPF")),
            TextField(controller: streetController, decoration: const InputDecoration(labelText: "Rua / Avenida")),
            TextField(controller: districtController, decoration: const InputDecoration(labelText: "Bairro")),
            TextField(controller: cityController, decoration: const InputDecoration(labelText: "Cidade")),
            TextField(controller: stateController, decoration: const InputDecoration(labelText: "Estado")),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Telefone")),

            const SizedBox(height:20),

            const Text("Responsável", style: TextStyle(fontSize:18,fontWeight:FontWeight.bold)),

            TextField(controller: dentistController, decoration: const InputDecoration(labelText: "Dentista responsável")),
            TextField(controller: croController, decoration: const InputDecoration(labelText: "CRO")),

            const Text("LOGIN", style: TextStyle(fontSize:18,fontWeight:FontWeight.bold)),

            TextField(controller: nicknameController,decoration: const InputDecoration(labelText: "Usuário (login)"),
            ),

           

            TextField(controller: passwordController,obscureText: true,decoration: const InputDecoration(labelText: "Senha"),
            ),

             TextField(controller: emailController,decoration: const InputDecoration(labelText: "E-mail"),
            ),
      
            const SizedBox(height:30),

            const Text("Autoclaves", style: TextStyle(fontSize:18,fontWeight:FontWeight.bold)),

            ElevatedButton.icon(
              icon: const Icon(Icons.bluetooth),
              label: const Text("Detectar Autoclaves"),
              onPressed: scanning ? null : detectAutoclaves,
            ),

            TextButton(
              onPressed: _addManualAutoclave,
              child: const Text("Cadastrar manualmente"),
            ),

            if(scanning)
              const Center(child: CircularProgressIndicator()),

            buildAutoclaves(),

            const SizedBox(height:40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Finalizar Cadastro"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}