import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<List<String>> fetchFileList() async {
    final response = await _dio.get('http://<server-ip>:3002/files');
    if (response.statusCode == 200) {
      return List<String>.from(response.data);
    } else {
      throw Exception('ファイル一覧の取得に失敗しました');
    }
  }
  
  Future<void> downloadFile(String url, String savePath) async {
    await _dio.download(url, savePath);
  }

  Future<void> uploadFile(String url, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    await _dio.post(url, data: formData);
  }
}
