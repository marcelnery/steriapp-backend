// PAGINA DO CADASTRO DO USUARIO ON LINE

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  List autoclaves = [];

  // =========================
  // CONTROLLERS
  // =========================

  final clinicController = TextEditingController();
  final cnpjController = TextEditingController();

  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();

  final dentistController = TextEditingController();
  final croController = TextEditingController();

  final emailController = TextEditingController();
  final phoneController = TextEditingController();

void showAddAutoclaveDialog() {

  final modelController = TextEditingController();
  final serialController = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Nova Autoclave"),
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
          onPressed: () async {

            final newAutoclave = {
              "brand": "Woson",
              "model": modelController.text,
              "serial": serialController.text,
            };

            await addAutoclaveToServer(newAutoclave);

            Navigator.pop(context);
          },
          child: const Text("Salvar"),
        )

      ],
    ),
  );
}
  

  // =========================
  // INIT
  // =========================

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // =========================
  // BUSCAR DADOS DO MONGO
  // =========================

  Future<void> loadUserData() async {

    final response = await http.get(
      Uri.parse("https://backend-nu-nine-29.vercel.app/api/user/marcelodontotec@gmail.com"),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      print("===== DADOS VINDOS DO MONGO =====");
      print(data);

      setState(() {

        clinicController.text = data["clinic"] ?? "";
        cnpjController.text = data["cnpj"] ?? "";

        streetController.text = data["address"]?["street"] ?? "";
        cityController.text = data["address"]?["city"] ?? "";
        stateController.text = data["address"]?["state"] ?? "";

        dentistController.text = data["dentist"] ?? "";
        croController.text = data["cro"] ?? "";
        emailController.text = data["email"]??"";
        phoneController.text = data["phone"]??"";

        autoclaves = data["autoclaves"]?? [];


      });

    } else {
      print("❌ Erro ao buscar usuário");
    }
  }

  Future<void> addAutoclaveToServer(Map<String, dynamic> autoclave) async {

    final response = await http.post(
      Uri.parse("https://backend-nu-nine-29.vercel.app/api/user/add-autoclave"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
  
          "email": emailController.text,
  "brand": "Woson",
  "model": autoclave["model"],
  "serial": autoclave["serial"],

      }),
    );

    if (response.statusCode == 200) {
      print("✅ Autoclave adicionada");
      await loadUserData();
    } else {
      print("❌ Erro ao adicionar");
    }
  }


Future<void> removeAutoclaveFromServer(String serial) async {

  final response = await http.post(
    Uri.parse("https://backend-nu-nine-29.vercel.app/api/user/remove-autoclave"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": emailController.text,
      "serial": serial,
    }),
  );

  if (response.statusCode == 200) {
    print("🗑️ Autoclave removida");
    await loadUserData(); // 🔥 atualiza tela
  } else {
    print("❌ Erro ao remover");
  }
}

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dados Cadastrais"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            const Text(
  "Dados de Acesso",
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),

const SizedBox(height: 10),

TextField(
  controller: emailController,
  decoration: const InputDecoration(labelText: "E-mail"),
  readOnly: true,
),

TextField(
  controller: phoneController,
  decoration: const InputDecoration(labelText: "Telefone"),
   readOnly: true,
  
),

            const Text(
              "Dados da Clínica",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: clinicController,
              decoration: const InputDecoration(labelText: "Nome da Clínica"),
               readOnly: true,
            ),

            TextField(
              controller: cnpjController,
              decoration: const InputDecoration(labelText: "CNPJ"),
               readOnly: true,
            ),

            const SizedBox(height: 20),

            const Text(
              "Endereço",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: streetController,
              decoration: const InputDecoration(labelText: "Rua"),
               readOnly: true,
            ),

            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: "Cidade"),
               readOnly: true,
            ),

            TextField(
              controller: stateController,
              decoration: const InputDecoration(labelText: "Estado"),
               readOnly: true,
            ),

            const SizedBox(height: 20),

            const Text(
              "Responsável",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              
            ),

            const SizedBox(height: 10),

            TextField(
              controller: dentistController,
              decoration: const InputDecoration(labelText: "Dentista"),
               readOnly: true,
            ),

            TextField(
              controller: croController,
              decoration: const InputDecoration(labelText: "CRO"),
               readOnly: true,
            ),

            const SizedBox(height: 30),

            const Text(
  "Autoclaves",
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),

const SizedBox(height: 10),

// 👇 BOTÃO AQUI
ElevatedButton.icon(
  onPressed: () => showAddAutoclaveDialog(),
  icon: const Icon(Icons.add),
  label: const Text("Adicionar Autoclave"),
),

const SizedBox(height: 15),

// 👇 LISTA
...autoclaves.take(3).map((a) {
  return GestureDetector(
    onTap: () async {

      final confirm = await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Remover Autoclave"),
          content: const Text("Deseja excluir esta autoclave?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Não"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Sim"),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await removeAutoclaveFromServer(a["serial"]);
      }
    },

    // 🔥  CARD ORIGINAl
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              const Icon(Icons.medical_services, color: Colors.purple),
              const SizedBox(width: 8),
              const Text(
                "WOSON",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text("Modelo: ${a["model"] ?? "-"}"),
          Text("Serial: ${a["serial"] ?? "-"}"),

        ],
      ),
    ),
  );
}).toList(),

           
          ],
        ),
      ),
    );
  }
}