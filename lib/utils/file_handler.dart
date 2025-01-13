import 'dart:io';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class FileHandler {
  // .xlsx ファイルをダウンロードして開く処理
  static Future<void> downloadAndOpenExcel(String folderName) async {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final String listFilesUrl = "http://192.168.3.12:3002/files?dir=/$folderName";
    final String localPathBase = "/storage/emulated/0/Download/";

    final Dio dio = Dio();
    final Uri parsedUri = Uri.tryParse(listFilesUrl) ??
        (throw ArgumentError('Invalid URL: $listFilesUrl'));

    try {
      // サーバーからフォルダ内のファイルリストを取得
      final response = await dio.get(parsedUri.toString());

      if (response.statusCode == 200) {
        List<dynamic> files = response.data;

        // .xlsx ファイルを検索
        String? excelFileName = files.firstWhere(
            (file) => file.toString().endsWith('.xlsx'),
            orElse: () => null);

        if (excelFileName == null) {
          throw Exception('No .xlsx file found in the specified folder.');
        }

        final String downloadUrl =
            "http://192.168.3.12:3002/files?dir=/$folderName/$excelFileName";
        final String localPath =
            "$localPathBase${excelFileName.split('.').first}_$today.xlsx";

        // .xlsx ファイルをダウンロード
        await dio.download(downloadUrl, localPath);

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
      } else {
        throw Exception('Failed to load files from server.');
      }
    } catch (e) {
      throw Exception('Error during download and open Excel: $e');
    }
  }

  // ファイルをサーバーにアップロードする処理
  static Future<void> uploadFile(String localFilePath, String folderName) async {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final String parentFolder = folderName.split('/').first; // 親フォルダ名を取得
    final String uploadUrl =
        "http://192.168.3.12:3002/files?dir=/$parentFolder/daily/$today";

    final Uri parsedUri = Uri.tryParse(uploadUrl) ??
        (throw ArgumentError('Invalid URL: $uploadUrl'));

    final Dio dio = Dio();

    try {
      // サーバー側でフォルダ作成を確認または新規作成
      await dio.post(
        "http://192.168.3.12:3002/create-folder",
        data: {'path': "/$parentFolder/daily/$today"},
      );

      // ファイルアップロード
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(localFilePath),
      });

      await dio.post(parsedUri.toString(), data: formData);

      // ローカルファイルを削除
      final file = File(localFilePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Error during file upload: $e');
    }
  }
}
