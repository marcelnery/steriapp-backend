// USUARIO 


import 'autoclave_model.dart';

class UserModel {

  final String email;
  final String clinicName;
  final String cnpj;
  final Map<String, dynamic> address;
  final String phone;
  final String dentist;
  final String cro;
  final List<AutoclaveModel> autoclaves;

  UserModel({
    required this.email,
    required this.clinicName,
    required this.cnpj,
    required this.address,
    required this.phone,
    required this.dentist,
    required this.cro,
    required this.autoclaves,
  });

  // =========================
  // FROM JSON
  // =========================
  factory UserModel.fromJson(Map<String, dynamic> json) {

    return UserModel(
      email: json["email"] ?? "",
      clinicName: json["clinic"] ?? "",
      cnpj: json["cnpj"] ?? "",
      address: json["address"] ?? {},
      phone: json["phone"] ?? "",
      dentist: json["dentist"] ?? "",
      cro: json["cro"] ?? "",
      autoclaves: (json["autoclaves"] as List? ?? [])
          .map((e) => AutoclaveModel.fromJson(e))
          .toList(),
    );
  }

  // =========================
  // TO JSON
  // =========================
  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "clinic": clinicName,
      "cnpj": cnpj,
      "address": address,
      "phone": phone,
      "dentist": dentist,
      "cro": cro,
      "autoclaves": autoclaves.map((a) => a.toJson()).toList(),
    };
  }
}