import 'package:flutter/material.dart';
import '../utils/api_service.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ファイルアップロード')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles();
            if (result != null) {
              final filePath = result.files.single.path!;
              await apiService.uploadFile('http://10.20.10.224:3002/upload', filePath);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('アップロードが完了しました'),
              ));
            }
          },
          child: Text('ファイルを選択してアップロード'),
        ),
      ),
    );
  }
}
