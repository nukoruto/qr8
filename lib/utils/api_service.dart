import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.20.10.224:3002"; // 固定IPアドレス

Future<List<String>> fetchFiles(String dir) async {
  final response = await http.get(
    Uri.parse('http://10.20.10.224:3002/files?dir=$dir'),
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
}
