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
      nicknameController.text.trim().toLowerCase(),
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
                           
                     Image.asset("assets/images/icon.png",
                    width: 120,
                  height: 120,
                    ),
                  

                const SizedBox(height: 20),

                const Text(
                  "SteriApp",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
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
  height: 58,

  child: ElevatedButton(

    onPressed: () async {

      // efeito pequeno ao clicar
      await Future.delayed(
        const Duration(milliseconds: 120),
      );

      login();
    },

    style: ElevatedButton.styleFrom(

      backgroundColor: wosonPurple,

      foregroundColor: Colors.white,

      elevation: 8,

      shadowColor: wosonPurple.withOpacity(0.5),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    child: const Text(
      "Entrar",

      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    ),
  ),
),
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