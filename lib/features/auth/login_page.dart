// TELA DE AUTENTICAÇÃO DO USUARIO PAGINA DO USUARIO PARA LOGAR E CADASTRO 

import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../dashboard/dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  void login() async {

    setState(() => loading = true);

    final success = await AuthService.login(
      nicknameController.text,
      passwordController.text,
    );

    setState(() => loading = false);

    if(success){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardPage(),
        ),
      );
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login inválido"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    const wosonPurple = Color(0xFF5E2B97);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF5E2B97),
              Color(0xFFEDE7F6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              children: [

                // LOGO / ICON
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    size: 60,
                    color: wosonPurple,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "STERIAPP",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 30),

                // CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      )
                    ],
                  ),

                  child: Column(
                    children: [

                      TextField(
                        controller: nicknameController,
                        decoration: const InputDecoration(
                          labelText: "Usuário",
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Senha",
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // BOTÃO ENTRAR
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: wosonPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: loading ? null : login,
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Entrar",
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // BOTÃO CADASTRO
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Não tem conta? Cadastre-se",
                          style: TextStyle(
                            color: wosonPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Produzido por Woson",
                  style: TextStyle(color: Colors.white70),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}