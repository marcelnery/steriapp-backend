import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_page.dart';

class SterilinkApp extends StatelessWidget {
  const SterilinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sterilink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}
