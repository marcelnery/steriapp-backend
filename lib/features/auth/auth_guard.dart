// controle de usuario para entrar e acessar o APP STERIAPP 

import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../dashboard/dashboard_page.dart';
import 'login_page.dart';

class AuthGuard extends StatefulWidget {

  const AuthGuard({super.key});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {

  bool? logged;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {

    final token = await AuthService.getToken();

    setState(() {
      logged = token != null;
    });

  }

  @override
  Widget build(BuildContext context) {

    /// ainda verificando login
    if(logged == null){
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    /// usuário logado
    if(logged == true){
      return const DashboardPage();
    }

    /// usuário não logado
    return const LoginPage();

  }

}