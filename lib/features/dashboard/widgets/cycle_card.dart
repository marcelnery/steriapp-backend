import 'package:flutter/material.dart';

class CycleCard extends StatelessWidget {
  const CycleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Ciclo Atual',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Tipo: Esterilização Classe B'),
            Text('Tempo: 18 min'),
            Text('Status: Em espera'),
          ],
        ),
      ),
    );
  }
}
