import 'dart:io';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class FileHandler {
  static Future<void> downloadAndOpenExcel(String directoryUrl) async {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final String downloadUrl = "$directoryUrl/inspection.xlsx";
    final String localPath = "/storage/emulated/0/Download/inspection_$today.xlsx";

    final Dio dio = Dio();
    await dio.download(downloadUrl, localPath);

    // エクセルアプリで開く
    await Process.run('am', ['start', '-a', 'android.intent.action.VIEW', '-d', 'file://$localPath', '-t', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']);
  }

  static Future<void> uploadFile(String localFilePath, String uploadUrl) async {
    final Dio dio = Dio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(localFilePath),
    });

    await dio.post(uploadUrl, data: formData);

    // ローカルファイルを削除
    final file = File(localFilePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
