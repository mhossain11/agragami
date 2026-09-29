import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/text_field.dart';
import '../../../res/apptextstyle.dart';
import '../controller/admin_monthly_receipt_controller.dart';
import '../model/receipt_data.dart';
import '../service/receipt_print_service.dart';
import '../service/thermal_printer_service.dart';

/// Admin screen to view a member's monthly money receipt and print it on a
/// Bluetooth thermal printer (58 mm ESC/POS).
class AdminMonthlyReceiptScreen extends GetView<AdminMonthlyReceiptController> {
  const AdminMonthlyReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Money Receipt'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('Member'),
            _memberCard(),
            const SizedBox(height: 16),
            _sectionTitle('Month'),
            _monthCard(),
            const SizedBox(height: 16),
            _viewReceiptButton(),
            const SizedBox(height: 16),
            _sectionTitle('Receipt Preview'),
            _receiptPreviewCard(),
            const SizedBox(height: 16),
            _printerSection(context),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Member
  // ------------------------------------------------------------------

  Widget _memberCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: controller.memberSearchController,
              labelText: 'Member ID',
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isSearchingMember.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ElevatedButton(
                onPressed: controller.searchMember,
                child: Text('Search', style: AppTextStyles.button),
              );
            }),
            const SizedBox(height: 8),
            Obx(() {
              final user = controller.selectedUser.value;
              if (user == null) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name : ${user.name}',
                      style: AppTextStyles.style12_bold,
                    ),
                    Text(
                      'ID      : ${user.userid}',
                      style: AppTextStyles.style12_normal,
                    ),
                    if (user.phone != null && user.phone!.isNotEmpty)
                      Text(
                        'Phone : ${user.phone}',
                        style: AppTextStyles.style12_normal,
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Month
  // ------------------------------------------------------------------

  Widget _monthCard() {
    final now = DateTime.now();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  // YEAR - small text, smaller share of the row
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      value: controller.selectedYear.value,
                      // Let the selected item shrink inside the field so a
                      // narrow screen / big system font never overflows.
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 14,
                        ),
                      ),
                      items: List.generate(10, (index) {
                        final year = now.year - 5 + index;
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(
                            '$year',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                      onChanged: (value) {
                        if (value == null) return;
                        controller.changeYear(value);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // MONTH - long names like "September", bigger share
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<int>(
                      value: controller.selectedMonth.value,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 14,
                        ),
                      ),
                      items: List.generate(12, (index) {
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(
                            AdminMonthlyReceiptController.monthNames[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                      onChanged: (value) {
                        if (value == null) return;
                        controller.changeMonth(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Selected : ${controller.monthLabel}',
                style: AppTextStyles.style12_bold,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _viewReceiptButton() {
    return Obx(() {
      return ElevatedButton(
        onPressed:
            controller.isLoadingRecords.value ? null : controller.viewReceipt,
        child: controller.isLoadingRecords.value
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text('View Receipt', style: AppTextStyles.button),
      );
    });
  }

  // ------------------------------------------------------------------
  // Receipt preview
  // ------------------------------------------------------------------

  Widget _receiptPreviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.isLoadingRecords.value) {
            return const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Loading monthly records...'),
              ],
            );
          }

          final data = controller.receipt.value;

          if (data == null) {
            if (controller.hasSearchedRecords.value) {
              return Text(
                'No money records found for ${controller.monthLabel}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 15),
              );
            }

            return const Text(
              'Select a member and month, then tap "View Receipt".',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            );
          }

          return _buildReceiptPreview(data);
        }),
      ),
    );
  }

  /// Renders the **exact lines the printer receives**
  /// (see `ReceiptPrintService.buildReceiptLines`), so the preview on
  /// screen always matches the paper - what you see is what is printed.
  ///
  /// Each printed line keeps a screen-friendly, monochrome look:
  /// * `-----` / `=====` rules become crisp lines
  /// * `label : value` rows keep one aligned colon column
  /// * date / amount / method rows keep their columns
  /// * double-size lines (AGRAGAMI, amount) render big and bold
  Widget _buildReceiptPreview(ReceiptData data) {
    final lines = controller.previewLines(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final line in lines) _previewLine(line)],
    );
  }

  /// Screen width (px) of the print service's 16-character label column.
  static const double _kvLabelWidth = 112;

  /// A printed transaction row starts with a date like `01-09-2026`.
  static final RegExp _transactionRowStart = RegExp(r'^\d{2}-\d{2}-\d{4}');

  /// Turns one printed [ReceiptLine] into screen widgets.
  Widget _previewLine(ReceiptLine line) {
    final text = line.text;

    // 1) blank line -> breathing room between blocks.
    if (text.isEmpty) return const SizedBox(height: 8);

    // 2) `-----` / `=====` -> crisp monochrome rules.
    if (_isRule(text)) {
      final strong = text.startsWith('=');
      return Container(
        height: strong ? 2 : 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: strong ? Colors.black : Colors.black45,
      );
    }

    // 3) `label : value` -> fixed label column, so every colon lines up.
    //    (The print service pads every label to 16 characters.)
    const labelColumn = 16;
    if (line.align == ReceiptAlign.left &&
        text.length > labelColumn &&
        text[labelColumn] == ':') {
      final label = text.substring(0, labelColumn).trimRight();
      final value = text.length > labelColumn + 1
          ? text.substring(labelColumn + 2).trimRight()
          : '';
      return _kvRow(label, value);
    }

    // 4) transaction rows keep date / amount / method columns.
    if (line.align == ReceiptAlign.left &&
        (text.startsWith('Date') || _transactionRowStart.hasMatch(text))) {
      return _transactionTableRow(text);
    }

    // 5) a wrapped value continues under the value column.
    if (line.align == ReceiptAlign.left && text.startsWith('  ')) {
      return Padding(
        padding: EdgeInsets.only(left: _kvLabelWidth + 10, top: 2, bottom: 2),
        child: Text(text.trim(), style: _previewStyle(line)),
      );
    }

    // 6) everything else (title, amount, footer) keeps its alignment.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text.trim(),
        textAlign: line.align == ReceiptAlign.center
            ? TextAlign.center
            : TextAlign.left,
        style: _previewStyle(line),
      ),
    );
  }

  /// Is [text] a full-width `-----` or `=====` rule?
  bool _isRule(String text) =>
      RegExp(r'^-+$').hasMatch(text) || RegExp(r'^=+$').hasMatch(text);

  /// Screen style of a printed line (bold and double size are kept).
  TextStyle _previewStyle(ReceiptLine line) {
    final doubleSize = line.size == ReceiptSize.double;
    return TextStyle(
      fontSize: doubleSize ? 20 : 13,
      fontWeight: line.bold || doubleSize ? FontWeight.bold : FontWeight.normal,
      height: 1.35,
      color: Colors.black,
    );
  }

  /// One `label : value` row with an aligned colon column.
  Widget _kvRow(String label, String value) {
    const labelStyle = TextStyle(fontSize: 13, color: Colors.black54);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _kvLabelWidth,
            child: Text(label, style: labelStyle),
          ),
          const Text(': ', style: labelStyle),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  /// One `01-09-2026     1,000  Cash Money` row (or its header row).
  Widget _transactionTableRow(String text) {
    final date = text.length >= 10 ? text.substring(0, 10).trim() : text;
    final rest = text.length > 12 ? text.substring(12).trim() : '';
    final parts = rest.split(RegExp(r'\s{2,}'));
    final amount = parts.isNotEmpty ? parts.first : '';
    final method = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final isHeader = date == 'Date';
    final style = TextStyle(
      fontSize: 13,
      height: 1.35,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      color: isHeader ? Colors.black54 : Colors.black,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(flex: 11, child: Text(date, style: style)),
          Expanded(
            flex: 9,
            child: Text(amount, textAlign: TextAlign.right, style: style),
          ),
          Expanded(flex: 12, child: Text(method, style: style)),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Printer
  // ------------------------------------------------------------------

  Widget _printerSection(BuildContext context) {
    return Obx(() {
      // No Bluetooth on web / unsupported platforms: hide gracefully.
      if (!controller.isPrinterSupported.value) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle('Printer'),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ----- status -----
                  Obx(() {
                    final connected = controller.isConnected.value;
                    return Row(
                      children: [
                        Icon(
                          Icons.bluetooth,
                          size: 18,
                          color: connected ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status: ${connected ? 'Connected' : 'Disconnected'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: connected ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                  Obx(() {
                    final printer = controller.selectedPrinter.value;
                    return Text(
                      printer == null
                          ? 'No printer selected.'
                          : 'Printer: ${printer.name}',
                      style: TextStyle(
                        color: printer == null ? Colors.grey : Colors.black,
                      ),
                    );
                  }),
                  const SizedBox(height: 12),

                  // ----- select + connect -----
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          return ElevatedButton.icon(
                            onPressed: controller.isSearchingPrinters.value
                                ? null
                                : () => _selectPrinterFlow(context),
                            icon: controller.isSearchingPrinters.value
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.bluetooth_searching),
                            label: const Text('Select Printer'),
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Obx(() {
                          if (controller.isConnecting.value) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (controller.isConnected.value) {
                            return ElevatedButton(
                              onPressed: controller.disconnect,
                              child: Text(
                                'Disconnect',
                                style: AppTextStyles.button,
                              ),
                            );
                          }

                          return ElevatedButton(
                            onPressed: controller.connect,
                            child: Text(
                              'Connect',
                              style: AppTextStyles.button,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ----- test + print -----
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          return ElevatedButton(
                            onPressed: controller.isPrinting.value
                                ? null
                                : controller.testPrint,
                            child: const Text('Test Print'),
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Obx(() {
                          final canPrint =
                              controller.receipt.value != null &&
                              !controller.isPrinting.value;

                          return ElevatedButton(
                            onPressed: canPrint
                                ? controller.printReceipt
                                : null,
                            child: controller.isPrinting.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Print Receipt'),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _selectPrinterFlow(BuildContext context) async {
    await controller.searchPrinters();

    if (!context.mounted) return;
    if (controller.pairedPrinters.isEmpty) return;

    await _showPrinterPicker(context);
  }

  Future<void> _showPrinterPicker(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select Bluetooth Printer'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.pairedPrinters.length,
              itemBuilder: (itemContext, index) {
                final PrinterDeviceInfo device =
                    controller.pairedPrinters[index];
                return ListTile(
                  leading: const Icon(Icons.print),
                  title: Text(device.name),
                  subtitle: Text(device.address),
                  onTap: () {
                    controller.selectPrinter(device);
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // Shared
  // ------------------------------------------------------------------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
