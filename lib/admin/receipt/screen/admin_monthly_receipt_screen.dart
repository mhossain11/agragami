import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/text_field.dart';
import '../../../res/apptextstyle.dart';
import '../controller/admin_monthly_receipt_controller.dart';
import '../model/receipt_data.dart';
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
                  // YEAR
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: controller.selectedYear.value,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(10, (index) {
                        final year = now.year - 5 + index;
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year'),
                        );
                      }),
                      onChanged: (value) {
                        if (value == null) return;
                        controller.changeYear(value);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // MONTH
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: controller.selectedMonth.value,
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(12, (index) {
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(
                            AdminMonthlyReceiptController.monthNames[index],
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

  Widget _buildReceiptPreview(ReceiptData data) {
    const bold = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);

    Widget kv(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text('$label : $value'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ----- header -----
        Center(
          child: Text(
            data.organizationName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const Center(child: Text(monthlyReceiptTitle, style: bold)),
        const Divider(),

        // ----- member block -----
        kv('Member Name', data.memberName),
        kv('Member ID', data.userId),
        kv('Month', data.monthLabel),
        const Divider(),

        // ----- transactions -----
        const Row(
          children: [
            Expanded(flex: 4, child: Text('Date', style: bold)),
            Expanded(
              flex: 3,
              child: Text('Amount', textAlign: TextAlign.right, style: bold),
            ),
            Expanded(flex: 4, child: Text('Method', style: bold)),
          ],
        ),
        const SizedBox(height: 4),
        for (final transaction in data.transactions)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(controller.formatDate(transaction.date)),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    controller.formatAmount(transaction.amount),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    transaction.paymentMethod,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        const Divider(),

        // ----- total -----
        Row(
          children: [
            const Expanded(flex: 4, child: Text('TOTAL', style: bold)),
            Expanded(
              flex: 3,
              child: Text(
                controller.formatAmount(data.total),
                textAlign: TextAlign.right,
                style: bold,
              ),
            ),
            const Expanded(flex: 4, child: SizedBox.shrink()),
          ],
        ),
        const Divider(),

        // ----- footer -----
        if (data.receivedBy.isNotEmpty) kv('Received By', data.receivedBy),
        kv('Date', controller.formatDate(data.generatedAt)),
        const SizedBox(height: 8),
        const Center(child: Text('Thank You')),
        Center(child: Text(data.organizationName)),
      ],
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
