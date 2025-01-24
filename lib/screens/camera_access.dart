import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../utils/api_service.dart'; // サーバーとの通信に使用

class CameraAccess {
  final ImagePicker _picker = ImagePicker();

  // カメラアクセス許可の確認
  Future<bool> requestCameraPermission() async {
    // カメラの権限はプラグインやAPIで確認してください（省略）
    return true;
  }

  // カメラを起動して画像を撮影
  Future<void> openCamera(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        // ローカルに保存
        final directory = await getApplicationDocumentsDirectory();
        final today = DateTime.now();
        final String folderPath = "${directory.path}/Pictures/${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}";

        // ディレクトリ作成
        final directoryFolder = Directory(folderPath);
        if (!await directoryFolder.exists()) {
          await directoryFolder.create(recursive: true);
        }

        final String localPath = "$folderPath/${image.name}";
        final File localFile = File(localPath);
        await localFile.writeAsBytes(await image.readAsBytes());

        // サーバーに送信
        await ApiService.uploadImageToServer(localPath);

        // 成功通知
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('画像が保存され、サーバーに送信されました')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('画像の保存または送信に失敗しました: $e')),
      );
    }
  }
}
