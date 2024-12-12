import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'file_viewer.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QRコードスキャナー')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (QRViewController controller) {
          controller.scannedDataStream.listen((scanData) {
            controller.pauseCamera();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FileViewerScreen(filePath: scanData.code!),
              ),
            );
          });
        },
      ),
    );
  }
}
