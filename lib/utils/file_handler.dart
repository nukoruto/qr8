import 'dart:io';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class FileHandler {
  static Future<void> downloadAndOpenExcel(String folderName) async {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final String downloadUrl = "http://10.20.10.224:3002/files?dir=/$folderName/inspection.xlsx";
    final String localPath = "/storage/emulated/0/Download/inspection_$today.xlsx";

    final Uri parsedUri = Uri.tryParse(downloadUrl) ??
        (throw ArgumentError('Invalid URL: $downloadUrl'));

    final Dio dio = Dio();
    // 正しいURLを渡してダウンロードを実行
    await dio.download(parsedUri.toString(), localPath);

    // エクセルアプリで開く
    await Process.run('am', [
      'start',
      '-a',
      'android.intent.action.VIEW',
      '-d',
      'file://$localPath',
      '-t',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ]);
  }

  static Future<void> uploadFile(String localFilePath, String folderName) async {
    final String uploadUrl = "http://10.20.10.224:3002/files?dir=/$folderName";

    final Uri parsedUri = Uri.tryParse(uploadUrl) ??
        (throw ArgumentError('Invalid URL: $uploadUrl'));

    final Dio dio = Dio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(localFilePath),
    });

    await dio.post(parsedUri.toString(), data: formData);

    // ローカルファイルを削除
    final file = File(localFilePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

