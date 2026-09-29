import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../user/money record/domain/model/money_record.dart';
import '../../../user/money record/domain/money_repository/moneyRecordRepository.dart';
import '../../save_money/model/usermodel.dart';
import '../../save_money/service/saving_money_service.dart';
import '../model/receipt_data.dart';
import '../service/receipt_print_service.dart';
import '../service/thermal_printer_service.dart';

/// Drives the admin "Monthly Money Receipt" screen: member search, month
/// selection, monthly money loading, receipt building and every thermal
/// printer action (list / connect / test print / print receipt).
///
/// No Firestore query and no Bluetooth call happens inside a widget.
class AdminMonthlyReceiptController extends GetxController {
  AdminMonthlyReceiptController({
    required MoneyRecordRepository moneyRecordRepository,
    required SavingMoneyService savingMoneyService,
    required ReceiptPrintService receiptPrintService,
    required ThermalPrinterService printerService,
  })  : _moneyRecordRepository = moneyRecordRepository,
        _savingMoneyService = savingMoneyService,
        _receiptPrintService = receiptPrintService,
        _printerService = printerService;

  final MoneyRecordRepository _moneyRecordRepository;
  final SavingMoneyService _savingMoneyService;
  final ReceiptPrintService _receiptPrintService;
  final ThermalPrinterService _printerService;

  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // ------------------------------------------------------------------
  // Member
  // ------------------------------------------------------------------
  final TextEditingController memberSearchController = TextEditingController();
  final RxBool isSearchingMember = false.obs;
  final Rx<UserModel?> selectedUser = Rx<UserModel?>(null);
  final RxString selectedUserDocId = ''.obs;

  // ------------------------------------------------------------------
  // Month
  // ------------------------------------------------------------------
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;

  /// `September 2026` - shown to the admin.
  String get monthLabel =>
      '${monthNames[selectedMonth.value - 1]} ${selectedYear.value}';

  /// `2026-09` - the project's existing `yyyy-MM` month key.
  String get monthKey =>
      '${selectedYear.value}-${selectedMonth.value.toString().padLeft(2, '0')}';

  // ------------------------------------------------------------------
  // Monthly records / receipt
  // ------------------------------------------------------------------
  final RxList<MoneyRecord> records = <MoneyRecord>[].obs;
  final RxBool isLoadingRecords = false.obs;
  final RxBool hasSearchedRecords = false.obs;
  final Rx<ReceiptData?> receipt = Rx<ReceiptData?>(null);

  double get totalAmount =>
      records.fold<double>(0.0, (sum, record) => sum + record.amount);

  // ------------------------------------------------------------------
  // Printer
  // ------------------------------------------------------------------
  final RxBool isPrinterSupported = false.obs;
  final RxList<PrinterDeviceInfo> pairedPrinters = <PrinterDeviceInfo>[].obs;
  final Rx<PrinterDeviceInfo?> selectedPrinter = Rx<PrinterDeviceInfo?>(null);
  final RxBool isSearchingPrinters = false.obs;
  final RxBool isConnecting = false.obs;
  final RxBool isConnected = false.obs;
  final RxBool isPrinting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _printerService.isSupported().then((supported) {
      isPrinterSupported.value = supported;
      if (supported) refreshConnectionStatus();
    });
  }

  @override
  void onClose() {
    memberSearchController.dispose();
    super.onClose();
  }

  // ------------------------------------------------------------------
  // Member search
  // ------------------------------------------------------------------

  /// Looks the member up by User ID (existing `SavingMoneyService` query).
  Future<void> searchMember() async {
    final userId = memberSearchController.text.trim();
    if (userId.isEmpty) {
      Get.snackbar('Member', 'Please enter a member ID.');
      return;
    }

    isSearchingMember.value = true;
    try {
      final result = await _savingMoneyService.searchUserWithDocId(userId);

      if (result == null) {
        selectedUser.value = null;
        selectedUserDocId.value = '';
        _clearReceipt();
        Get.snackbar('Error', 'No user found with ID: $userId');
        return;
      }

      selectedUser.value = result.user;
      selectedUserDocId.value = result.userDocId;
      _clearReceipt();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSearchingMember.value = false;
    }
  }

  // ------------------------------------------------------------------
  // Month selection
  // ------------------------------------------------------------------
  void changeYear(int year) {
    if (selectedYear.value == year) return;
    selectedYear.value = year;
    _clearReceipt();
  }

  void changeMonth(int month) {
    if (selectedMonth.value == month) return;
    selectedMonth.value = month;
    _clearReceipt();
  }

  void _clearReceipt() {
    records.clear();
    receipt.value = null;
    hasSearchedRecords.value = false;
  }

  // ------------------------------------------------------------------
  // Monthly records + receipt
  // ------------------------------------------------------------------

  /// Fetches only the selected member's money for the selected month and
  /// builds the receipt preview. Shows the no-data state when empty.
  Future<void> viewReceipt() async {
    if (selectedUser.value == null || selectedUserDocId.value.isEmpty) {
      Get.snackbar('Member', 'Please search and select a member first.');
      return;
    }

    isLoadingRecords.value = true;
    hasSearchedRecords.value = false;
    receipt.value = null;

    try {
      final month = DateTime(selectedYear.value, selectedMonth.value);
      final data = await _moneyRecordRepository.getMonthlyMoneyRecords(
        userDocId: selectedUserDocId.value,
        month: month,
      );

      records.assignAll(data);
      hasSearchedRecords.value = true;

      if (data.isNotEmpty) {
        receipt.value = _buildReceipt(data);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoadingRecords.value = false;
    }
  }

  ReceiptData _buildReceipt(List<MoneyRecord> data) {
    final fallbackDate = DateTime(selectedYear.value, selectedMonth.value, 1);
    final generatedAt = DateTime.now();
    final userId = selectedUser.value?.userid ?? '';

    return ReceiptData(
      organizationName: appOrganizationName,
      title: monthlyReceiptTitle,
      memberName: selectedUser.value?.name ?? '',
      userId: userId,
      monthLabel: monthLabel,
      // Receipt metadata - pure derivations from data we already have.
      receiptNo: buildReceiptNo(userId, generatedAt),
      instalmentNo: buildInstalmentNo(data.length),
      collectionType: monthlyCollectionType,
      paymentMode: buildPaymentMode([
        for (final record in data) record.paymentMethod,
      ]),
      remarks: monthlyReceiptRemarks,
      transactions: [
        for (final record in data)
          ReceiptTransaction(
            date: record.dateTime ?? record.collectionDate ?? fallbackDate,
            amount: record.amount,
            paymentMethod: record.paymentMethod,
          ),
      ],
      total: data.fold<double>(0.0, (sum, record) => sum + record.amount),
      receivedBy: data.last.receivedBy,
      generatedAt: generatedAt,
    );
  }

  /// Shared amount formatting (same source the printer uses).
  String formatAmount(num amount) => _receiptPrintService.formatAmount(amount);

  /// Shared date formatting (same source the printer uses).
  String formatDate(DateTime date) => _receiptPrintService.formatDate(date);

  /// The exact lines the printer will receive - the screen preview renders
  /// these, so what you see on screen is what ends up on paper (WYSIWYG).
  List<ReceiptLine> previewLines(ReceiptData data) =>
      _receiptPrintService.buildReceiptLines(data);

  // ------------------------------------------------------------------
  // Printer
  // ------------------------------------------------------------------

  Future<void> refreshConnectionStatus() async {
    if (!isPrinterSupported.value) return;
    isConnected.value = await _printerService.isConnected();
  }

  /// Lists the printers already paired in system Bluetooth settings.
  Future<void> searchPrinters() async {
    if (!isPrinterSupported.value) {
      Get.snackbar(
        'Printer',
        'Bluetooth printing is not supported on this device.',
      );
      return;
    }

    isSearchingPrinters.value = true;
    try {
      if (!await _printerService.ensurePermission()) {
        pairedPrinters.clear();
        Get.snackbar('Permission', 'Bluetooth permission is required.');
        return;
      }

      if (!await _printerService.isBluetoothEnabled()) {
        pairedPrinters.clear();
        Get.snackbar('Bluetooth', 'Please enable Bluetooth.');
        return;
      }

      final printers = await _printerService.getPairedPrinters();
      pairedPrinters.assignAll(printers);

      if (printers.isEmpty) {
        Get.snackbar(
          'Printer',
          'No paired printer found. Pair the printer in the phone\'s '
              'Bluetooth settings first.',
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSearchingPrinters.value = false;
    }
  }

  Future<void> selectPrinter(PrinterDeviceInfo device) async {
    selectedPrinter.value = device;
    isConnected.value = await _printerService.isConnected();
  }

  Future<void> connect() async {
    final printer = selectedPrinter.value;
    if (printer == null) {
      Get.snackbar('Printer', 'Please select a printer first.');
      return;
    }

    isConnecting.value = true;
    try {
      if (!await _printerService.ensurePermission()) {
        Get.snackbar('Permission', 'Bluetooth permission is required.');
        return;
      }

      if (!await _printerService.isBluetoothEnabled()) {
        Get.snackbar('Bluetooth', 'Please enable Bluetooth.');
        return;
      }

      final connected = await _printerService.connect(printer.address);
      isConnected.value = connected;

      if (connected) {
        Get.snackbar('Printer', 'Printer connected.');
      } else {
        Get.snackbar('Connection', 'Unable to connect to printer.');
      }
    } catch (e) {
      isConnected.value = false;
      Get.snackbar('Connection', 'Unable to connect to printer.');
    } finally {
      isConnecting.value = false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _printerService.disconnect();
    } finally {
      isConnected.value = false;
    }
    Get.snackbar('Printer', 'Printer disconnected.');
  }

  Future<void> testPrint() async {
    final ready = await _ensureReadyForPrinting(
      notConnectedMessage: 'Printer is not connected.',
    );
    if (!ready) return;

    isPrinting.value = true;
    try {
      final success = await _receiptPrintService.printTest();
      if (success) {
        Get.snackbar('Printer', 'Test print sent.');
      } else {
        Get.snackbar('Printer', 'Printing failed. Please try again.');
      }
    } finally {
      isPrinting.value = false;
    }
  }

  Future<void> printReceipt() async {
    final data = receipt.value;
    if (data == null) {
      Get.snackbar(
        'Receipt',
        'No receipt to print. Please view a receipt first.',
      );
      return;
    }

    final ready = await _ensureReadyForPrinting();
    if (!ready) return;

    isPrinting.value = true;
    try {
      final success = await _receiptPrintService.printReceipt(data);
      if (success) {
        Get.snackbar('Success', 'Receipt printed successfully.');
      } else {
        Get.snackbar('Printer', 'Printing failed. Please try again.');
      }
    } finally {
      isPrinting.value = false;
    }
  }

  /// Shared guards for anything that needs a live connection.
  Future<bool> _ensureReadyForPrinting({
    String notConnectedMessage = 'Please connect a thermal printer first.',
  }) async {
    if (!isPrinterSupported.value) {
      Get.snackbar(
        'Printer',
        'Bluetooth printing is not supported on this device.',
      );
      return false;
    }

    if (selectedPrinter.value == null) {
      Get.snackbar('Printer', notConnectedMessage);
      return false;
    }

    final connected = await _printerService.isConnected();
    isConnected.value = connected;

    if (!connected) {
      Get.snackbar('Printer', notConnectedMessage);
      return false;
    }

    return true;
  }
}
