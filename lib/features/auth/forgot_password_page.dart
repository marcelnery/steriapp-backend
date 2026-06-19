import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {

  final emailController =
      TextEditingController();

  bool loading = false;

  Future<void> sendRecovery() async {

    setState(() {
      loading = true;
    });

    try {

      final response = await http.post(

        Uri.parse(
          "https://backend-nu-nine-29.vercel.app/api/forgot-password",
        ),

        headers: {
          "Content-Type":
              "application/json",
        },

        body: jsonEncode({
          "email":
              emailController.text.trim(),
        }),

      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Enviamos um E-mail para recuperação de sua conta cadastrada.",
          ),
        ),

      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Erro ao enviar recuperação.",
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
          "Recuperar Senha",
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller:
                  emailController,
              decoration:
                  const InputDecoration(
                labelText: "E-mail",
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed:
                    loading
                        ? null
                        : sendRecovery,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Enviar Recuperação",
                      ),

              ),
            ),

          ],
        ),
      ),
    );
  }
}