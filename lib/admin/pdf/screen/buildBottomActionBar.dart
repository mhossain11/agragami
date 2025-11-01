import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../service/pdf_service.dart';

class BuildBottomActionBar extends StatefulWidget {
   BuildBottomActionBar({super.key, required this.currentUserId});

  String currentUserId;

  @override
  State<BuildBottomActionBar> createState() => _BuildBottomActionBarState();
}

class _BuildBottomActionBarState extends State<BuildBottomActionBar> {
  bool _isLoading = false;
  Future<void> _generateAndShowPDF() async {
    if (widget.currentUserId.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final pdf = await PdfService.generateUserMoneyPDF(widget.currentUserId);
      await Printing.layoutPdf(
        onLayout: (format) => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _printPDF() async {
    if (widget.currentUserId.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final pdf = await PdfService.generateUserMoneyPDF(widget.currentUserId);
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'financial-report-${widget.currentUserId}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing PDF: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.picture_as_pdf),
              label: Text('Generate PDF'),
              onPressed: _generateAndShowPDF,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.print),
              label: Text('Print PDF'),
              onPressed: _printPDF,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade300,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

