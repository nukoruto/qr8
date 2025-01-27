import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/api_service.dart';
import 'file_list.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> checkAndRequestCameraPermission() async {
  final status = await Permission.camera.status;
  if (!status.isGranted) {
    await Permission.camera.request();
  }
}

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final ApiService _apiService = ApiService();
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;
  late String qrData; // qrDataを宣言

  @override
  void initState() {
    super.initState();
    checkAndRequestCameraPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRコードスキャナ'),
      ),
      body: MobileScanner(
        controller: _scannerController,
        onDetect: (BarcodeCapture capture) {
          if (!_hasScanned) {
            _hasScanned = true;
            final barcode = capture.barcodes.first; // 最初の検出結果を取得
            if (barcode.rawValue != null) {
              qrData = barcode.rawValue!; // qrDataに値を代入
              _handleBarcodeScan(context, qrData);
            }
          }
        },
      ),
    );
  }

  void _handleBarcodeScan(BuildContext context, String directoryUrl) async {
    try {
      final files = await _apiService.fetchFiles(directoryUrl);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileListScreen(folderName: qrData), // qrDataを使用
        ),
      ).then((_) {
        // 戻ってきたときに再びスキャンを許可
        setState(() {
          _hasScanned = false;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $e')),
      );
      setState(() {
        _hasScanned = false;
      });
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}
