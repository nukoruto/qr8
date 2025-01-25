import 'dart:io';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileHandler {
  static Future<Directory> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  static Future<String> getScopedStorageFilePath(String fileName) async {
    // 外部ストレージディレクトリを取得
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception('External storage directory not accessible.');
    }

    // ダウンロードフォルダを取得
    final downloadPath = '${directory.path}/Download';
    final filePath = '$downloadPath/$fileName';

    return filePath;
  }

  // サーバーから指定されたフォルダ内の指定拡張子のファイル名を取得
  static Future<String?> fetchFileName(String folderName, String extension) async {
    final String listFilesUrl = "http://192.168.3.13:3002/files?dir=/$folderName";
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

  // 指定したフォルダのファイルをダウンロードし、ダウンロードフォルダにコピーして開く
  static Future<void> downloadAndOpenFile(String folderName, String extension,
      {String? renamedFileName}) async {
    final String? fileName = await fetchFileName(folderName, extension);
    if (fileName == null) {
      throw Exception('No $extension file found in the specified folder.');
    }

    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final String downloadUrl =
        "http://192.168.3.13:3002/file?filePath=$folderName/$fileName";
    final Directory appDir = await getAppDirectory();
    final String tempPath = "${appDir.path}/temp_$fileName";

    final Dio dio = Dio();
    await dio.download(downloadUrl, tempPath);

    // ダウンロードフォルダにコピー
    final Directory? downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw Exception('Unable to access downloads directory.');
    }
    final String finalPath =
        "${downloadsDir.path}/${renamedFileName ?? "${fileName.split('.').first}_$today.$extension"}";
    await File(tempPath).copy(finalPath);

    // コピー後のファイルをデフォルトアプリで開く
    final result = await OpenFilex.open(finalPath);
    if (result.type != ResultType.done) {
      throw Exception('Failed to open file: ${result.message}');
    }
  }

  // ACTION_OPEN_DOCUMENTを使用してファイルを取得
  static Future<String?> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      return result.files.first.path;
    }
    return null;
  }

  // 指定したローカルパスのファイルをサーバーにアップロード
  static Future<void> uploadFile(String localFilePath) async {
    final String today = DateFormat('yyyyMMdd').format(DateTime.now());
    final String uploadUrl = "http://192.168.3.13:3002/upload";

    final String dailyFolderPath = "/daily/$today";
    final Uri parsedUri = Uri.tryParse(uploadUrl) ??
        (throw ArgumentError('Invalid URL: $uploadUrl'));

    final Dio dio = Dio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(localFilePath),
      'targetDir': dailyFolderPath,
    });

    await dio.post(parsedUri.toString(), data: formData);

    // ローカルファイルの削除
    final file = File(localFilePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
