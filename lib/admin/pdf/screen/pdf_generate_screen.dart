// lib/screens/user_money_pdf_screen.dart
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../service/pdf_service.dart';

class UserMoneyPdfScreen extends StatelessWidget {
  final String userDocId;
  final _moneyService = PdfService();

  UserMoneyPdfScreen({super.key, required this.userDocId});

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    // 🔹 Fetch money data using service
    final moneyData = await _moneyService.fetchMoneyData(userDocId);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Text(
              'User Money Report',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // Table with data
          pw.Table.fromTextArray(
            headers: ['Date', 'Title', 'Type', 'Amount (Tk)'],
            data: moneyData.map((m) {
              return [
                m['date'] != null
                    ? "${m['date'].day}-${m['date'].month}-${m['date'].year}"
                    : '',
                m['title'],
                m['type'],
                m['amount'].toString(),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
            cellAlignment: pw.Alignment.centerLeft,
          ),

          pw.SizedBox(height: 20),

          // Total
          pw.Text(
            "Total Amount: ${moneyData.fold<num>(0, (sum, item) => sum + (item['amount'] ?? 0))} Tk",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );

    // Show PDF preview
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Money Report')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _generatePdf(context),
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Generate PDF'),
        ),
      ),
    );
  }
}
