import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './login_page.dart';

class ResetPasswordPage extends StatefulWidget {

  final String token;

  const ResetPasswordPage({
    super.key,
    required this.token,
  });

  @override
  State<ResetPasswordPage> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState
    extends State<ResetPasswordPage> {

  final passwordController =
      TextEditingController();

  bool loading = false;

  Future<void> resetPassword() async {

    setState(() {
      loading = true;
    });

    try {

      final response = await http.post(

        Uri.parse(
          "https://backend-nu-nine-29.vercel.app/api/reset-password",
        ),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({

          "token": widget.token,

          "password":
              passwordController.text.trim(),

        }),
      );

      if (response.statusCode == 200) {

        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              "Senha alterada com sucesso",
            ),
          ),
        );

      Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (_) => const LoginPage(),
  ),
  (route) => false,
);

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              "Token inválido ou expirado",
            ),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Erro ao redefinir senha",
          ),
        ),
      );

    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Nova Senha",
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nova Senha",
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed:
                    loading
                        ? null
                        : resetPassword,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Salvar Nova Senha",
                      ),

              ),
            ),
          ],
        ),
      ),
    );
  }
}