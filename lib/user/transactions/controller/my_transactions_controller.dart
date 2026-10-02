import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../screen/my_transactions_pdf_preview_screen.dart';
import '../service/my_transactions_pdf_service.dart';

/// Drives the "My Transactions" page.
///
/// The PDF is always generated for the member who is signed in to
/// Firebase Auth right now: [MyTransactionsPdfService.generateUserMoneyPDF]
/// takes no arguments, so no screen can ever request another member's
/// transactions.
class MyTransactionsController extends GetxController {
  MyTransactionsController({required MyTransactionsPdfService pdfService})
      : _pdfService = pdfService;

  final MyTransactionsPdfService _pdfService;

  /// True while the statement is being generated.
  final isGenerating = false.obs;

  /// True once a PDF has been generated in this session.
  final hasGeneratedPdf = false.obs;

  Uint8List? _pdfBytes;
  String? _fileName;

  /// Generates the signed-in member's own transaction statement.
  Future<void> generatePdf() async {
    if (isGenerating.value) return;
    isGenerating.value = true;

    try {
      final document = await _pdfService.generateUserMoneyPDF();
      _pdfBytes = await document.save();
      _fileName =
          'Agragami_Transactions_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
      hasGeneratedPdf.value = true;
    } catch (e) {
      hasGeneratedPdf.value = false;
      Get.snackbar(
        'Error',
        'Could not generate the PDF: '
            '${e.toString().replaceFirst('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  /// Opens the generated PDF in the on-screen viewer.
  void viewPdf() {
    final bytes = _pdfBytes;
    if (bytes == null) return;
    Get.to(() => MyTransactionsPdfPreviewScreen(pdfBytes: bytes));
  }

  /// Saves the generated PDF to the device (public Downloads folder on
  /// Android, app documents folder elsewhere) and shows where it went.
  Future<void> downloadPdf() async {
    final bytes = _pdfBytes;
    final fileName = _fileName;
    if (bytes == null || fileName == null) return;

    try {
      final savedPath = await _savePdfToDevice(bytes, fileName);
      Get.snackbar(
        'Saved',
        'PDF saved to: $savedPath',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not save the PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Shares the generated PDF through the device's normal share sheet
  /// (WhatsApp, email, Messenger, ...).
  Future<void> sharePdf() async {
    final bytes = _pdfBytes;
    final fileName = _fileName;
    if (bytes == null || fileName == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(file.path, mimeType: 'application/pdf', name: fileName),
          ],
          title: 'Agragami Transaction Statement',
          text: 'My transaction statement from Agragami.',
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not share the PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Writes [bytes] to the device and returns a human readable location.
  ///
  /// Android: public `Downloads/Agragami/` folder via the MediaStore API
  /// (no permission needed on Android 11+). Older versions fall back to
  /// the app's own storage when MediaStore is unavailable.
  Future<String> _savePdfToDevice(Uint8List bytes, String fileName) async {
    if (!Platform.isAndroid) {
      return _saveToAppDocuments(bytes, fileName);
    }

    await MediaStore.ensureInitialized();
    MediaStore.appFolder = 'Agragami';

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(bytes, flush: true);

    try {
      final info = await MediaStore().saveFile(
        tempFilePath: tempFile.path,
        dirType: DirType.download,
        dirName: DirName.download,
      );
      if (info != null) {
        return 'Downloads/Agragami/${info.name}';
      }
    } catch (_) {
      // Fall back to app storage below (e.g. very old Android versions).
    }

    return _saveToAppDocuments(bytes, fileName);
  }

  Future<String> _saveToAppDocuments(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
