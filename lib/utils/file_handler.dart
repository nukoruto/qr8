import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FileHandler {
  Future<String> getTemporaryFilePath(String fileName) async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/$fileName';
  }

  Future<void> deleteTemporaryFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
