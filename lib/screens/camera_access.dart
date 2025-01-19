import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:html' as html; // Web環境用の画像保存
import 'dart:io'; // 非Webデバイス用のファイル操作
import 'package:path_provider/path_provider.dart'; // ファイル保存場所を取得
import 'package:image_gallery_saver/image_gallery_saver.dart'; // ギャラリーに保存


class CameraAccess {
  // カメラのアクセス権をリクエスト
  Future<bool> requestCameraPermission() async {
    return true; // `permission_handler` 使用時は元のコードを残してください
  }

  // カメラを起動
  void openCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraAccessScreen()),
    );
  }
}



// カメラ管理とプレビュー画面のクラスを統合
class CameraAccessScreen extends StatefulWidget {
  @override
  _CameraAccessScreenState createState() => _CameraAccessScreenState();
}

class _CameraAccessScreenState extends State<CameraAccessScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // 使用可能なカメラを初期化するメソッド
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(_cameras.first, ResolutionPreset.high, enableAudio: false);
        await _cameraController.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('カメラの初期化に失敗しました: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }


// 保存先を選択するダイアログを表示
  Future<void> _showSaveLocationDialog(String filePath, List<int> bytes) async {
    if (Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.android) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('アプリ内に保存'),
                onTap: () {
                  Navigator.pop(context);
                  _saveImageToAppDirectory(filePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_album),
                title: const Text('ギャラリーに保存'),
                onTap: () {
                  Navigator.pop(context);
                  _saveImageToGallery(filePath);
                },
              ),
            ],
          );
        },
      );
    } else {
      _saveImageWeb('camera_image.png', bytes);
    }
  }


  // 画像を保存する処理（Web用）
  void _saveImageWeb(String fileName, List<int> bytes) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = fileName;
    anchor.click();

    html.Url.revokeObjectUrl(url);
  }





  // アプリ内ディレクトリに保存
  Future<void> _saveImageToAppDirectory(String filePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory(); // ドキュメントディレクトリを取得
      final file = File('${directory.path}/camera_image_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(await File(filePath).readAsBytes()); // 画像を保存
      print('アプリ内に画像を保存しました: ${file.path}');
    } catch (e) {
      print('画像保存に失敗しました: $e');
    }
  }

  // ギャラリーに保存
  Future<void> _saveImageToGallery(String filePath) async {
    try {
      await ImageGallerySaver.saveFile(filePath);
      print('ギャラリーに画像を保存しました: $filePath');
    } catch (e) {
      print('ギャラリー保存に失敗しました: $e');
    }
  }

  // 写真を撮って保存する
  Future<void> _takePicture() async {
    try {
      if (_cameraController.value.isInitialized) {
        final image = await _cameraController.takePicture();

        // 保存先を選択する
        final imageBytes = await image.readAsBytes();
        _showSaveLocationDialog(image.path, imageBytes);
      }
    } catch (e) {
      print('写真撮影に失敗しました: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カメラ機能')),
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController),
                Positioned(
                  bottom: 50,
                  left: 100,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 40, color: Colors.white),
                    onPressed: _takePicture,
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
