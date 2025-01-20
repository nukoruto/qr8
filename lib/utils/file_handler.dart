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

  // .xlsx と .pdf ファイルを検索
       // 指定された拡張子のファイルをすべて取得
      List<String> targetFiles = files
          .where((file) => file.toString().endsWith(fileType))
          .cast<String>()
          .toList();

      if (targetFiles.isEmpty) {
        throw Exception('No $fileType file found in the specified folder.');
      }

      // 最初の対象ファイルを選択
      final String targetFile = targetFiles.first;
      final String downloadUrl = "http://192.168.3.12:3002/file?filePath=$folderName/$targetFile";

      if (fileType == '.xlsx') {
        // エクセルファイルの場合はリネームして保存
        final String localPath = "$localPathBase${targetFile.split('.').first}_$today$fileType";
        await dio.download(downloadUrl, localPath);
        final result = await OpenFilex.open(localPath);
        print('Attempting to open file at: $localPath');
        if (result.type != ResultType.done) {
          throw Exception('Failed to open the file: $localPath');
        }
      } else if (fileType == '.pdf') {
        // PDFファイルの場合はリネームせずそのまま保存
        final String localPath = "$localPathBase$targetFile";
        await dio.download(downloadUrl, localPath);
        final result = await OpenFilex.open(localPath);
        print('Attempting to open file at: $localPath');
        if (result.type != ResultType.done) {
          throw Exception('Failed to open the file: $localPath');
        }
      }
    } else {
      throw Exception('Failed to load files from server.');
    }
  }
}
