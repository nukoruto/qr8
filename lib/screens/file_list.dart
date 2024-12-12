import 'package:flutter/material.dart';
import '../utils/api_service.dart';

class FileListScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ファイル一覧')),
      body: FutureBuilder(
        future: apiService.fetchFileList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました'));
          } else {
            final List<String> files = snapshot.data as List<String>;
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(files[index]),
                  onTap: () {
                    // ファイル選択時の処理
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
