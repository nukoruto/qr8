import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart';

class ApiService {
  final String baseUrl = "http://192.168.3.13:3002"; // 固定IPアドレス

Future<List<String>> fetchFiles(String dir) async {
  final response = await http.get(
    Uri.parse('http://192.168.3.13:3002/files?dir=$dir'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> files = jsonDecode(response.body);
    return files.cast<String>();
  } else {
    throw Exception('Failed to load files');
  }
}


  Future<void> uploadFile(String filePath, String uploadDirectory) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    request.fields['directory'] = uploadDirectory;
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    var response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to upload file');
    }
  }
  static Future<void> uploadImageToServer(String filePath) async {
    final String uploadUrl = "http://192.168.3.13:3002/upload-image";
    final dio = Dio();

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await dio.post(uploadUrl, data: formData);

      if (response.statusCode == 200) {
        print('画像がサーバーに正常にアップロードされました');
      } else {
        print('画像のアップロードに失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
    }
  }
}
