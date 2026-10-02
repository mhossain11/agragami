import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/model/my_transactions_data.dart';
import '../domain/repository/my_transactions_repository.dart';

/// Builds the "My Transactions" PDF statement for the member who is
/// signed in right now.
///
/// [generateUserMoneyPDF] takes **no user id**: the logged-in Firebase
/// Auth user is identified inside [MyTransactionsRepository], so no UI
/// can ever ask this service for somebody else's transactions.
class MyTransactionsPdfService {
  MyTransactionsPdfService(this._repository);

  final MyTransactionsRepository _repository;

  /// Loads the signed-in member's data and renders the statement PDF.
  Future<pw.Document> generateUserMoneyPDF() async {
    final data = await _repository.loadMyTransactions();

    final doc = pw.Document();
    final logo = await _tryLoadLogo();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (context) => [
          _header(logo),
          pw.SizedBox(height: 18),
          _memberBox(data),
          pw.SizedBox(height: 18),
          _transactionsTable(data),
          pw.SizedBox(height: 18),
          _summaryBox(data),
          pw.SizedBox(height: 30),
          _signatureSection(),
        ],
      ),
    );

    return doc;
  }

  // ------------------------------------------------------------------
  // Header + member information
  // ------------------------------------------------------------------

  /// Organisation logo from the assets, or `null` when it is missing so
  /// the statement still prints with a text-only header.
  Future<pw.MemoryImage?> _tryLoadLogo() async {
    try {
      final bytes = await rootBundle.load('assets/images/agrogami_logo.png');
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  pw.Widget _header(pw.MemoryImage? logo) {
    return pw.Container(
      padding: pw.EdgeInsets.only(bottom: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.red, width: 2),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logo != null) ...[
            pw.Container(
              width: 56,
              height: 56,
              child: pw.Image(logo, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(width: 12),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'AGRAGAMI',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
                pw.Text(
                  'Member Transaction Statement',
                  style: pw.TextStyle(
                    fontSize: 13,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Generated on',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              pw.Text(
                DateFormat('dd-MM-yyyy').format(DateTime.now()),
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _memberBox(MyTransactionsData data) {
    pw.Widget infoRow(String label, String value) {
      return pw.Padding(
        padding: pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 110,
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                value.isEmpty ? 'N/A' : value,
                style: pw.TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      );
    }

    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'MEMBER INFORMATION',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red,
            ),
          ),
          pw.SizedBox(height: 8),
          infoRow('Name', data.name),
          infoRow('User ID', data.userId),
          infoRow('Email', data.email),
          infoRow('Phone', data.phone),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Transaction history
  // ------------------------------------------------------------------

  pw.Widget _transactionsTable(MyTransactionsData data) {
    const headers = [
      '#',
      'Transaction ID',
      'Date',
      'Amount',
      'Payment Method',
    ];

    pw.Widget cell(String text, {bool header = false}) {
      return pw.Container(
        padding: pw.EdgeInsets.all(6),
        color: header ? PdfColors.grey200 : PdfColors.white,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: header ? 10 : 9,
            fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
          textAlign: header ? pw.TextAlign.center : pw.TextAlign.left,
        ),
      );
    }

    final dateFormat = DateFormat('dd-MM-yyyy');
    final amountFormat = NumberFormat('#,##0.##');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'TRANSACTION HISTORY',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.red,
          ),
        ),
        pw.SizedBox(height: 8),
        if (data.transactions.isEmpty)
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Text(
              'No transactions found.',
              style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
          )
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: pw.FlexColumnWidth(0.5),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(1.2),
              3: pw.FlexColumnWidth(1.2),
              4: pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                children: headers.map((header) => cell(header, header: true)).toList(),
              ),
              ...data.transactions.asMap().entries.map((entry) {
                final record = entry.value;
                final date = record.dateTime == null
                    ? 'N/A'
                    : dateFormat.format(record.dateTime!);
                final method = record.paymentMethod.trim().isEmpty
                    ? 'N/A'
                    : record.paymentMethod;

                return pw.TableRow(
                  children: [
                    cell('${entry.key + 1}'),
                    cell(record.id),
                    cell(date),
                    cell('Tk ${amountFormat.format(record.amount)}'),
                    cell(method),
                  ],
                );
              }),
            ],
          ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Summary + signature
  // ------------------------------------------------------------------

  pw.Widget _summaryBox(MyTransactionsData data) {
    pw.Widget summaryRow(String label, String value) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      );
    }

    final amountFormat = NumberFormat('#,##0.##');
    final total = 'Tk ${amountFormat.format(data.totalTransactionAmount)}';

    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        children: [
          summaryRow('Total Transactions:', '${data.totalTransactionCount}'),
          pw.SizedBox(height: 6),
          summaryRow('Total Transaction Amount:', total),
          pw.SizedBox(height: 6),
          summaryRow(
            'Total Collected Amount:',
            'Tk ${amountFormat.format(data.totalCollectedAmount)}',
          ),
        ],
      ),
    );
  }

  pw.Widget _signatureSection() {
    pw.Widget signatureColumn(String title) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Container(
            width: 200,
            height: 1,
            color: PdfColors.grey600,
          ),
          pw.SizedBox(height: 6),
          pw.Text('Signature', style: pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 14),
          pw.Text('Date: ________________', style: pw.TextStyle(fontSize: 10)),
        ],
      );
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        signatureColumn('Member Signature'),
        signatureColumn('Authorized Signature'),
      ],
    );
  }
}
