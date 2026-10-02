import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/my_transactions_controller.dart';

/// "My Transactions" - generates a PDF statement of the signed-in
/// member's own account.
///
/// There is deliberately **no** field to enter or pick a user id: the PDF
/// is always built from the logged-in Firebase Auth session.
class MyTransactionsScreen extends GetView<MyTransactionsController> {
  const MyTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Transactions'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _introCard(),
            const SizedBox(height: 20),
            _generateButton(),
            const SizedBox(height: 16),
            Obx(() {
              if (!controller.hasGeneratedPdf.value) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _readyCard(),
                  const SizedBox(height: 12),
                  _actionButton(
                    icon: Icons.visibility,
                    label: 'View PDF',
                    onPressed: controller.viewPdf,
                  ),
                  const SizedBox(height: 10),
                  _actionButton(
                    icon: Icons.download,
                    label: 'Download PDF',
                    onPressed: controller.downloadPdf,
                  ),
                  const SizedBox(height: 10),
                  _actionButton(
                    icon: Icons.share,
                    label: 'Share PDF',
                    onPressed: controller.sharePdf,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: const Row(
        children: [
          Icon(Icons.receipt_long, size: 42, color: Colors.red),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Generate a professional PDF statement of your own '
                  'account - name, user ID, every transaction, totals and '
                  'signature. It always uses the member you are logged in '
                  'with, so no ID needs to be typed.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _generateButton() {
    return Obx(() {
      final generating = controller.isGenerating.value;
      return SizedBox(
        height: 54,
        child: ElevatedButton.icon(
          onPressed: generating ? null : controller.generatePdf,
          icon: generating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.picture_as_pdf, size: 26),
          label: Text(
            generating ? 'Generating PDF...' : 'Generate PDF',
            style: const TextStyle(fontSize: 17),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.red.shade300,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    });
  }

  Widget _readyCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 28),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your transaction PDF is ready. Choose an option below.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 15)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
