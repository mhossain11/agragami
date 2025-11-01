import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // Add this for asset loading

class PdfService {
  static Future<pw.Document> generateUserMoneyPDF(String userId) async {
    final doc = pw.Document();

    // Get user data
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    // Get money transactions
    final moneySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Money')
        .orderBy('date&time', descending: true)
        .get();

    final userData = userDoc.data();
    final moneyData = moneySnapshot.docs;

    try {
      // Load logo from assets
      final logo = await _loadLogo();

      // Add content to PDF with logo
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            _buildHeaderWithLogo(logo, userData),
            pw.SizedBox(height: 20),
            _buildUserInfo(userData),
            pw.SizedBox(height: 20),
            _buildMoneyTable(moneyData),
            pw.SizedBox(height: 20),
            _buildSummary(moneyData),
            pw.SizedBox(height: 30),
            _buildSignatureSpace(),
          ],
        ),
      );
    } catch (e) {
      // Fallback: Generate PDF without logo if logo loading fails
      print('Error loading logo: $e');
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            _buildHeader(userData),
            pw.SizedBox(height: 20),
            _buildUserInfo(userData),
            pw.SizedBox(height: 20),
            _buildMoneyTable(moneyData),
            pw.SizedBox(height: 20),
            _buildSummary(moneyData),
            pw.SizedBox(height: 30),
            _buildSignatureSpace(),
          ],
        ),
      );
    }

    return doc;
  }

  // Method to load logo from assets
  static Future<pw.MemoryImage> _loadLogo() async {
    try {
      final byteData = await rootBundle.load('assets/images/agrogami_logo.png');
      return pw.MemoryImage(byteData.buffer.asUint8List());
    } catch (e) {
      throw Exception('Failed to load logo: $e');
    }
  }

  // Header with logo
  static pw.Widget _buildHeaderWithLogo(pw.MemoryImage logo, Map<String, dynamic>? userData) {
    return pw.Column(
      children: [
        // Logo and company name row
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.Container(
              width: 60,
              height: 60,
              child: pw.Image(logo, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(width: 10),
            pw.Center(
              child: pw.Text(
                'AGRAGAMI FINANCIAL REPORT',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
          ),
        ),
      ],
    );
  }

  // Original header without logo (fallback)
  static pw.Widget _buildHeader(Map<String, dynamic>? userData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Center(
          child: pw.Text(
            'AGRAGAMI FINANCIAL REPORT',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildUserInfo(Map<String, dynamic>? userData) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'USER INFORMATION',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green700,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Text('Name: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(userData?['name'] ?? 'N/A'),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text('Email: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(userData?['email'] ?? 'N/A'),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text('UserId: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(userData?['user_id'] ?? 'N/A'),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Text('Phone: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(userData?['phone'] ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMoneyTable(List<QueryDocumentSnapshot> moneyData) {
    // Updated headers to include Transaction ID
    final headers = ['Transaction ID', 'Date', 'Amount', 'Payment Method'];

    return pw.Column(
      children: [
        pw.Text(
          'TRANSACTION HISTORY',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green700,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: pw.FlexColumnWidth(1.5), // Transaction ID - wider
            1: pw.FlexColumnWidth(1.2), // Date
            2: pw.FlexColumnWidth(1.0), // Amount
            3: pw.FlexColumnWidth(1.3), // Payment Method
          },
          children: [
            // Header row
            pw.TableRow(
              children: headers.map((header) =>
                  pw.Container(
                    padding: pw.EdgeInsets.all(6),
                    color: PdfColors.grey200,
                    child: pw.Text(
                      header,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  )
              ).toList(),
            ),
            // Data rows
            ...moneyData.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final transactionId = doc.id; // Get the document ID as transaction ID
              final date = data['date&time'] != null
                  ? DateFormat('yyyy-MM-dd').format((data['date&time'] as Timestamp).toDate())
                  : 'N/A';
              final amount = data['amount']?.toString() ?? '0';
              final paymentMethod = data['payment_method'] ?? 'N/A';

              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(6),
                    child: pw.Text(
                      transactionId,
                      style: pw.TextStyle(fontSize: 9),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(6),
                    child: pw.Text(
                      date,
                      style: pw.TextStyle(fontSize: 9),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(6),
                    child: pw.Text(
                      '\$$amount',
                      style: pw.TextStyle(fontSize: 9),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(6),
                    child: pw.Text(
                      paymentMethod,
                      style: pw.TextStyle(fontSize: 9),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  // Helper method to format transaction ID (shorten if too long)
  static String _formatTransactionId(String transactionId) {
    if (transactionId.length > 12) {
      return '${transactionId.substring(0, 8)}...';
    }
    return transactionId;
  }

  static pw.Widget _buildSummary(List<QueryDocumentSnapshot> moneyData) {
    final totalAmount = moneyData.fold<double>(0, (sum, doc) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      return sum + amount;
    });

    final totalTransactions = moneyData.length;

    return pw.Column(
      children: [
      /*  // Total Transactions
        pw.Container(
          padding: pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Transactions:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                totalTransactions.toString(),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),*/
        // Total Amount
        pw.Container(
          padding: pw.EdgeInsets.all(5),
          decoration: pw.BoxDecoration(
            color: PdfColors.green50,
            border: pw.Border.all(color: PdfColors.green300),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Amount:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSignatureSpace() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        //divider
      /*  pw.Container(
          width: double.infinity,
          height: 1,
          color: PdfColors.grey400,
          margin: pw.EdgeInsets.only(bottom: 10),
        ),*/
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Authorized Signature',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Container(
                  width: 200,
                  height: 1,
                  color: PdfColors.grey400,
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Name: ___________________',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Date: ___________________',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
            /*pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Member Signature',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Container(
                  width: 200,
                  height: 1,
                  color: PdfColors.grey400,
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Name: ___________________',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Date: ___________________',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
            ),*/
          ],
        ),
      ],
    );
  }
}




