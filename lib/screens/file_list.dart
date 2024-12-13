import 'package:flutter/material.dart';
import '../utils/file_handler.dart';
import 'file_viewer.dart';

class FileListScreen extends StatelessWidget {
  final String directoryUrl;

  FileListScreen({required this.directoryUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ファイル一覧")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await FileHandler.downloadAndOpenExcel(directoryUrl);
            },
            child: const Text("点検簿"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FileViewerScreen(fileUrl: "$directoryUrl/manual.pdf"),
                ),
              );
            },
            child: const Text("マニュアル"),
          ),
        ],
      ),
    );
  }
}
