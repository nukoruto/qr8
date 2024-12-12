import 'package:file_picker/file_picker.dart';

class FilePickerHelper {
  /// ファイルを選択するメソッド
  /// [allowedExtensions] により選択可能な拡張子を指定できます。
  static Future<String?> pickFile({List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        return result.files.single.path; // 選択されたファイルのパス
      } else {
        return null; // ファイル選択がキャンセルされた場合
      }
    } catch (e) {
      print("ファイル選択中にエラーが発生しました: $e");
      return null;
    }
  }
}
