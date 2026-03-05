import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  const ActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.bluetooth),
            label: const Text('Conectar'),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Histórico'),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
