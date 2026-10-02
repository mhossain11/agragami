import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Full-screen viewer for the generated statement ("View PDF").
class MyTransactionsPdfPreviewScreen extends StatelessWidget {
  const MyTransactionsPdfPreviewScreen({super.key, required this.pdfBytes});

  /// The saved PDF document.
  final Uint8List pdfBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => pdfBytes,
        canChangePageFormat: false,
        canChangeOrientation: false,
        allowSharing: false,
        maxPageWidth: 700,
        pdfFileName: 'Agragami_Transactions.pdf',
      ),
    );
  }
}
