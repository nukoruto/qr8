import 'dart:io';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class FileHandler {
  static Future<Directory> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  // サーバーから指定されたフォルダ内の指定拡張子のファイル名を取得
  static Future<String?> fetchFileName(String folderName, String extension) async {
    final String listFilesUrl = "http://10.20.10.224:3002/files?dir=/$folderName";
    final Dio dio = Dio();
    final Uri parsedUri = Uri.tryParse(listFilesUrl) ??
        (throw ArgumentError('Invalid URL: $listFilesUrl'));

    final response = await dio.get(parsedUri.toString());

    if (response.statusCode == 200) {
      List<dynamic> files = response.data;
      String? fileName = files.firstWhere(
          (file) => file.toString().endsWith(extension),
          orElse: () => null);
      return fileName;
    } else {
      throw Exception('Failed to fetch files from server.');
    }
  }

  // 指定したフォルダのファイルをダウンロードし、必要に応じてリネーム
  static Future<void> downloadAndOpenFile(String folderName, String extension,
      {String? renamedFileName}) async {
    final String? fileName = await fetchFileName(folderName, extension);
    if (fileName == null) {
      throw Exception('No $extension file found in the specified folder.');
    }

    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final String downloadUrl =
        "http://10.20.10.224:3002/file?filePath=$folderName/$fileName";
    final Directory appDir = await getAppDirectory();
    final String localPath = "${appDir.path}/" +
        (renamedFileName ?? "${fileName.split('.').first}_$today.$extension");

    final Dio dio = Dio();
    await dio.download(downloadUrl, localPath);

    // ファイルをデフォルトアプリで開く
    final result = await OpenFilex.open(localPath);
    if (result.type != ResultType.done) {
      throw Exception('Failed to open file: ${result.message}');
    }
  }

  // 指定したローカルパスのファイルをサーバーにアップロード
  static Future<void> uploadFile(String localFilePath, String parentFolder) async {
    final String today = DateFormat('yyyyMMdd').format(DateTime.now());
    final String uploadUrl = "http://10.20.10.224:3002/upload";

    final String dailyFolderPath = "/$parentFolder/daily/$today";
    final Uri parsedUri = Uri.tryParse(uploadUrl) ??
        (throw ArgumentError('Invalid URL: $uploadUrl'));

    final Dio dio = Dio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(localFilePath),
      'targetDir': dailyFolderPath,
    });

try {
    await dio.post(uploadUrl, data: formData);

    // アップロード成功後にローカルファイルを削除
    final file = File(localFilePath);
    if (await file.exists()) {
      await file.delete();
    }
    print("アップロードが完了し、ローカルファイルが削除されました。");
  } catch (e) {
    print("アップロードに失敗しました: $e");
    throw Exception("アップロードエラー: $e");
  }
}
}
