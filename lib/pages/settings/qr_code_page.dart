import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatelessWidget {
  const QRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SnapMeal QR Code'),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: QrImageView(
          data: 'https://sites.google.com/view/snapmeal',
          version: QrVersions.auto, // Let it decide the best version
          size: 180,
          gapless: false,
          errorStateBuilder: (cxt, err) {
            return const Center(
              child: Text(
                'Uh oh! Something went wrong...',
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }
}
