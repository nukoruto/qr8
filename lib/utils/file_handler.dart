import 'dart:io';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class FileHandler {
  // サーバーから指定されたフォルダ内の指定拡張子のファイル名を取得
  static Future<String?> fetchFileName(String folderName, String extension) async {
    final String listFilesUrl = "http://192.168.3.13:3002/files?dir=/$folderName";
    final Dio dio = Dio();
    final Uri parsedUri = Uri.tryParse(listFilesUrl) ??
        (throw ArgumentError('Invalid URL: $listFilesUrl'));

    final response = await dio.get(parsedUri.toString());

    if (response.statusCode == 200) {
      List<dynamic> files = response.data;
      return files.firstWhere(
        (file) => file.toString().endsWith(extension),
        orElse: () => null,
      );
    } else {
      throw Exception('Failed to fetch files from server.');
    }
  }

  // 点検簿をダウンロードし、デフォルトアプリで開く
static const platform = MethodChannel('file_permissions');

  static Future<void> downloadAndOpenFile(
      String folderName, String extension,
      {String? renamedFileName}) async {
    final String? fileName = await fetchFileName(folderName, extension);
    if (fileName == null) {
      throw Exception('No $extension file found in the specified folder.');
    }

    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final String downloadUrl =
        "http://192.168.3.13:3002/file?filePath=$folderName/$fileName";

    // ダウンロードフォルダへのパスを取得
    final Directory downloadsDir = Directory('/storage/emulated/0/Download');
    final String localPath = "${downloadsDir.path}/" +
        (renamedFileName ?? "${fileName.split('.').first}_$today.$extension");

    final Dio dio = Dio();
    await dio.download(downloadUrl, localPath);

    final file = File(localPath);

    // 属性変更前の確認
    final statBefore = await file.stat();
    print("変更前の属性: mode=${statBefore.mode}, size=${statBefore.size}");

    try {
      if (await file.exists()) {
        // ネイティブメソッドで属性を変更
        final success = await platform.invokeMethod('setFilePermissions', {
          'path': localPath,
          'readable': true,
          'writable': true,
          'executable': false,
        });

        if (success) {
          print("ファイル属性を更新しました。");
        } else {
          print("ファイル属性の更新に失敗しました。");
        }

        // 属性変更後の確認
        final statAfter = await file.stat();
        print("変更後の属性: mode=${statAfter.mode}, size=${statAfter.size}");
      }
    } catch (e) {
      throw Exception('Failed to reset file attributes: $e');
    }
    
    // 手動確認用のコードを追加
print("手動確認: ファイルの読み取り可能性: ${file.readAsBytesSync() != null}");

    // ファイルをデフォルトアプリで開く
    final result = await OpenFilex.open(localPath);
    if (result.type != ResultType.done) {
      throw Exception('Failed to open file: ${result.message}');
    }
  }



  // 点検簿をアップロード
  static Future<void> uploadFile(String folderName) async {
    // ダウンロードフォルダからファイルを選択
    final result = await FilePicker.platform.pickFiles(
      initialDirectory: '/storage/emulated/0/Download',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      final String localFilePath = result.files.single.path!;
      final String uploadUrl = "http://192.168.3.13:3002/upload";

      final Dio dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(localFilePath),
        'targetDir': folderName,
      });

      await dio.post(uploadUrl, data: formData);

      // アップロード成功後、ローカルファイルを削除
      final file = File(localFilePath);
      if (await file.exists()) {
        await file.delete();
      }
    } else {
      throw Exception("ファイル選択がキャンセルされました。");
    }
  }
}
