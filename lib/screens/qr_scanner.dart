import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'file_list.dart';

class QRScannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QRコードをスキャン"),
      ),
      body: MobileScanner(
  onDetect: (BarcodeCapture barcodeCapture) {
    if (barcodeCapture.barcodes.isNotEmpty) {
      final String? directoryUrl = barcodeCapture.barcodes.first.rawValue;
      if (directoryUrl != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FileListScreen(directoryUrl: directoryUrl),
          ),
        );
      }
    }
  },
),

    );
  }
}
