import 'package:flutter/material.dart';
import 'package:qr8/utils/file_handler.dart';
import 'package:qr8/screens/file_viewer.dart';

class FileListScreen extends StatelessWidget {
  final String folderName;

  FileListScreen({required this.folderName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ファイルリスト")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                await FileHandler.downloadAndOpenFile(folderName, '.xlsx');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('エラー: $e')),
                );
              }
            },
            child: const Text("点検簿をダウンロード"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FileHandler.downloadAndOpenFile(folderName, '.pdf');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('エラー: $e')),
                );
              }
            },
            child: const Text("マニュアルを開く"),
          ),
        ],
      ),
    );
  }
}
