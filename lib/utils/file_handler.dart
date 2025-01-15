import 'dart:io';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class FileHandler {
  static Future<dynamic> downloadAndOpenFile(String folderName, String fileType) async {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final String listFilesUrl = "http://10.20.10.224:3002/files?dir=/$folderName";
    final String localPathBase = "/storage/emulated/0/Download/";

    final Dio dio = Dio();
    final Uri parsedUri = Uri.tryParse(listFilesUrl) ??
        (throw ArgumentError('Invalid URL: $listFilesUrl'));

    // サーバーからフォルダ内のファイルリストを取得
    final response = await dio.get(parsedUri.toString());

    if (response.statusCode == 200) {
      List<dynamic> files = response.data;

      // 指定されたファイルタイプを検索
      String? targetFile = files.firstWhere(
          (file) => file.toString().endsWith(fileType),
          orElse: () => null);

      if (targetFile == null) {
        throw Exception('No $fileType file found in the specified folder.');
      }

      final String downloadUrl = "http://10.20.10.224:3002/file?filePath=$folderName/$targetFile";
      final String localPath = "$localPathBase${targetFile.split('.').first}_$today$fileType";

      // ファイルをダウンロード
      await dio.download(downloadUrl, localPath);

      final Uri fileUri = Uri.file(localPath);
      print('Attempting to open file at: $localPath');
      if (fileType == '.xlsx') {
        // エクセルファイルの場合はアプリで開く
Future<void> openFileWithIntent(String filePath) async {
  try {
    final intent = AndroidIntent(
      action: 'action_view',
      data: Uri.file(filePath).toString(),
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  } catch (e) {
    print('Error launching intent: $e');
  }
}
}
      else if (fileType == '.pdf') {
        // PDFファイルの場合はパスを返す
        return localPath;
      }
    } else {
      throw Exception('Failed to load files from server.');
    }
  }
}
