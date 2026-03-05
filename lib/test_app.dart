import 'package:flutter/material.dart';

import 'features/dashboard/dashboard_page.dart';
import 'features/cycles/pages/cycles_page.dart';

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Modo Teste')),
        body: ListView(
          children: [
            ListTile(
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DashboardPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Histórico de Ciclos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CyclesPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
