import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'file_viewer.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController scannerController = MobileScannerController();

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QRコードスキャナー')),
      body: MobileScanner(
        controller: scannerController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              scannerController.stop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FileViewerScreen(filePath: barcode.rawValue!),
                ),
              );
              break;
            }
          }
        },
      ),
    );
  }
}
