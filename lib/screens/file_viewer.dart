import 'package:flutter/material.dart';
import '../utils/file_handler.dart';
import '../utils/api_service.dart';

class FileViewerScreen extends StatelessWidget {
  final String filePath;

  FileViewerScreen({required this.filePath});

  final ApiService apiService = ApiService();
  final FileHandler fileHandler = FileHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ファイルビューア')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final tempPath = await fileHandler.getTemporaryFilePath(filePath.split('/').last);
                await apiService.downloadFile('http://<server-ip>:3002/download/$filePath', tempPath);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('ファイルをダウンロードしました'),
                ));
              },
              child: Text('ファイルをダウンロード'),
            ),
            ElevatedButton(
              onPressed: () {
                // ダウンロード後に外部アプリで開く処理
              },
              child: Text('ファイルを開く'),
            ),
          ],
        ),
      ),
    );
  }
}
