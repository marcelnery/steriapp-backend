import 'package:flutter/material.dart';
import '../data/error_codes.dart';

class ErrorParametersPage extends StatelessWidget {

  const ErrorParametersPage({super.key});

  @override
  Widget build(BuildContext context) {

    const wosonPurple = Color(0xFF5E2B97);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Parâmetros de Erros",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: wosonPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: errorCodes.length,
        itemBuilder: (context, index) {

          final error = errorCodes[index];

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade100,
                child: Text(
                  error.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),

              title: Text(
                error.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(error.description),
            ),
          );
        },
      ),
    );
  }
}