import 'dart:io';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

class FileHandler {
  static Future<dynamic> downloadAndOpenFile(String folderName, String fileType) async {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final String listFilesUrl = "http://192.168.3.12:3002/files?dir=/$folderName";
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

      final String downloadUrl = "http://192.168.3.12:3002/file?filePath=$folderName/$targetFile";
      final String localPath = "$localPathBase${targetFile.split('.').first}_$today$fileType";

      // ファイルをダウンロード
      await dio.download(downloadUrl, localPath);

      final Uri fileUri = Uri.file(localPath);
      print('Attempting to open file at: $localPath');
      if (fileType == '.xlsx') {
        // エクセルファイルの場合はアプリで開く

      final result = await OpenFilex.open(localPath);
            if (result.type != ResultType.done) {
        throw Exception('Failed to open the file: $localPath');
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
