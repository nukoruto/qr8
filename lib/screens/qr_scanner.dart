import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/api_service.dart';
import '../utils/file_handler.dart';
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

  @override
  void initState() {
    super.initState();
    // 初期化処理をここに追加できます
    checkAndRequestCameraPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRコードスキャナ'),
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) {
          final barcode = capture.barcodes.first; // 最初の検出結果を取得
          if (barcode.rawValue != null) {
            final directoryUrl = barcode.rawValue!;
            _handleBarcodeScan(context, directoryUrl);
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
          builder: (context) => FileListScreen(files: files, directoryUrl: directoryUrl),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $e')),
      );
    }
  }
}
