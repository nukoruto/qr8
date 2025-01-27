import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr8/utils/file_handler.dart';
import '../main.dart';
import 'package:permission_handler/permission_handler.dart';

class FileListScreen extends StatefulWidget {
  final String folderName;

  const FileListScreen({Key? key, required this.folderName}) : super(key: key);

  @override
  _FileListScreenState createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  String? excelFileName;

  @override
  void initState() {
    super.initState();
    _fetchExcelFileName();
  }

  Future<void> _fetchExcelFileName() async {
    try {
      final fileName = await FileHandler.fetchFileName(widget.folderName, '.xlsx');
      setState(() {
        excelFileName = fileName;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エクセルファイル名の取得に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text("ファイルリスト")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              if (await Permission.manageExternalStorage.request().isDenied) {
  // ユーザーに権限を有効化してもらう
  await openAppSettings();
}

               if (excelFileName == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('エクセルファイルが見つかりません')),
                );
                return;
              }

              final renamedFileName = excelFileName!.replaceAll('.xlsx', '_$today.xlsx');
              try {
                await FileHandler.downloadAndOpenFile(
                  widget.folderName,
                  '.xlsx',
                  renamedFileName: renamedFileName,
                );
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
  if (excelFileName == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('アップロードするファイルがありません')),
    );
    return;
  }

  try {
    await FileHandler.uploadFile(widget.folderName);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('アップロードが完了しました')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('アップロードに失敗しました: $e')),
    );
  }
},

            child: const Text("点検簿を送信"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FileHandler.downloadAndOpenFile(widget.folderName, '.pdf');
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
