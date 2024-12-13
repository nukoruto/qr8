import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class FileViewerScreen extends StatelessWidget {
  final String fileUrl;

  FileViewerScreen({required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDFビューア")),
      body: PDFView(filePath: fileUrl),
    );
  }
}
