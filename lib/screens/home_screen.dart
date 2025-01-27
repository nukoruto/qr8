import 'package:flutter/material.dart';
import 'qr_scanner.dart';
import 'camera_access.dart'; // 新規カメラ管理クラスのインポート

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRコードで管理'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScannerScreen()),
                );
              },
              child: const Text('QRコードを読み取る'),
            ),


            const SizedBox(height: 20), // スペースを追加

            ElevatedButton(
              onPressed: () async {
                final cameraAccess = CameraAccess();
                final hasAccess = await cameraAccess.requestCameraPermission();
                if (hasAccess) {
                  cameraAccess.openCamera(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('カメラのアクセスが拒否されました')),
                  );
                }
              },
              child: const Text('カメラ'),
            )
          ],
        ),
      ),
    );
  }
}
