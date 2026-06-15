import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/auth_guard.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // =========================
    // ANIMAÇÕES
    // =========================
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation =
        Tween<double>(begin: 0.85, end: 1.0).animate(_fadeAnimation);

    _controller.forward();

    // =========================
    // TIMER → DASHBOARD
    // =========================
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AuthGuard(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        child: Stack(
          children: [
            // =========================
            // CONTEÚDO ORIGINAL (INTACTO)
            // =========================
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // =========================
                      // BRASÃO
                      // =========================
                     Image.asset(
                                 "assets/images/icon.png",
                                width: 140,
                                  height: 140,
                                ),

                      const SizedBox(height: 24),

                      // =========================
                      // NOME DO APP
                      // =========================
                      const Text(
                        'SteriApp',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Seu App da saúde que cria um link até você',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // =========================
                      // CRÉDITOS
                      // =========================
                      const Text(
                        'Produzido por Woson',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Criado por Odontotec Santos\nBy Marcel Nery',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // =========================
            // LOGO WOSON (ACRESCENTADA)
            // =========================
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/images/logo_da_woson.png',
                  height: 90,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}