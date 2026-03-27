// A PONTE PARA AUTENTICAR COM O REGISTRO DE BACKEND SALVO

/* AQUI FICA O LOGIN
               LOGOUT
               SALVAR TOKEN
               VERIFICAR SESSÃO
*/               


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  static const baseUrl = "https://backend-nu-nine-29.vercel.app";

  /// REGISTER
static Future<bool> register({
  required String nickname,
    required String email,
  required String password,
  required String clinic,
  required String cnpj,
  required Map<String, String> address,
  required String phone,
  required String dentist,
  required String cro,
  required List<Map<String, dynamic>> autoclaves,
}) async {

  try {

    final response = await http.post(
      Uri.parse("$baseUrl/api/register"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "nickname": nickname,
        "email": email,
        "password": password,
        "clinic": clinic,
        "cnpj": cnpj,
        "address": address,
        "phone": phone,
        "dentist": dentist,
        "cro": cro,
        "autoclaves": autoclaves,
      }),
    );

    // 🔥 DEBUG (IMPORTANTE)
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    return false;

  } catch (e) {

    print("ERRO REGISTER: $e");
    return false;

  }
}
  /// LOGIN
  static Future<bool> login(String nickname, String password) async {

    final response = await http.post(
      Uri.parse("$baseUrl/api/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nickname": nickname,
        "password": password
      }),
    );

    if(response.statusCode == 200){

      final data = jsonDecode(response.body);

      final token = data["token"];

      await saveToken(token);
      _tokenCache = token;

      return true;
    }

    return false;
  }

  /// SALVAR TOKEN
  static Future<void> saveToken(String token) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("auth_token", token);

  }

  /// PEGAR TOKEN
  static Future<String?> getToken() async {

    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("auth_token");

  }

  /// VERIFICAR SE ESTÁ LOGADO
  static bool isLogged() {

    // versão simples para AuthGuard
    return _tokenCache != null;

  }

  static String? _tokenCache;

  /// CARREGAR TOKEN AO INICIAR APP
  static Future<void> init() async {

    final prefs = await SharedPreferences.getInstance();

    _tokenCache = prefs.getString("auth_token");

  }

  /// LOGOUT
  static Future<void> logout() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("auth_token");

    _tokenCache = null;

  }

}