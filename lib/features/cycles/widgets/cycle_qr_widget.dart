import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CycleQrWidget extends StatelessWidget {
  final String url;

  const CycleQrWidget({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QrImageView(
          data: url,
          size: 200,
          backgroundColor: Colors.white,
        ),
        const SizedBox(height: 12),
        const Text(
          'Escaneie para acessar o laudo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
