import 'package:Agragami/admin/receipt/model/receipt_data.dart';
import 'package:Agragami/admin/receipt/service/receipt_print_service.dart';
import 'package:Agragami/admin/receipt/service/thermal_printer_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory printer so the test never touches real Bluetooth.
class FakeThermalPrinterService implements ThermalPrinterService {
  List<int>? lastBytes;
  bool connected = false;
  bool printResult = true;

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<bool> ensurePermission() async => true;

  @override
  Future<bool> isBluetoothEnabled() async => true;

  @override
  Future<List<PrinterDeviceInfo>> getPairedPrinters() async => const [];

  @override
  Future<bool> isConnected() async => connected;

  @override
  Future<bool> connect(String address) async {
    connected = true;
    return true;
  }

  @override
  Future<bool> disconnect() async {
    connected = false;
    return true;
  }

  @override
  Future<bool> printBytes(List<int> bytes) async {
    lastBytes = List<int>.from(bytes);
    return printResult;
  }
}

ReceiptData sampleReceipt() => ReceiptData(
      organizationName: appOrganizationName,
      title: monthlyReceiptTitle,
      memberName: 'Faysal Hossain',
      userId: 'AG26U001',
      monthLabel: 'September 2026',
      transactions: [
        ReceiptTransaction(
          date: DateTime(2026, 9, 1),
          amount: 1000,
          paymentMethod: 'Cash Money',
        ),
        ReceiptTransaction(
          date: DateTime(2026, 9, 10),
          amount: 1500,
          paymentMethod: 'Bank',
        ),
        ReceiptTransaction(
          date: DateTime(2026, 9, 20),
          amount: 1000,
          paymentMethod: 'Bkash',
        ),
      ],
      total: 3500,
      receivedBy: 'Admin',
      generatedAt: DateTime(2026, 9, 27),
    );

void main() {
  late FakeThermalPrinterService printer;
  late ReceiptPrintService service;

  setUp(() {
    printer = FakeThermalPrinterService();
    service = ReceiptPrintService(printer);
  });

  group('formatAmount', () {
    test('groups thousands', () {
      expect(service.formatAmount(1000), '1,000');
      expect(service.formatAmount(15000), '15,000');
      expect(service.formatAmount(999), '999');
      expect(service.formatAmount(0), '0');
    });

    test('keeps non-zero cents', () {
      expect(service.formatAmount(125000.5), '125,000.50');
      expect(service.formatAmount(12.34), '12.34');
    });
  });

  group('formatDate', () {
    test('formats as dd-MM-yyyy', () {
      expect(service.formatDate(DateTime(2026, 9, 27)), '27-09-2026');
      expect(service.formatDate(DateTime(2026, 1, 5)), '05-01-2026');
    });
  });

  group('line helpers', () {
    test('centerText pads both sides', () {
      expect(service.centerText('X', 10), '    X     ');
      expect(service.centerText('X', 10).length, 10);
    });

    test('leftRightText puts right side on the last column', () {
      final line = service.leftRightText('TOTAL', '3,500', 32);
      expect(line.length, 32);
      expect(line, startsWith('TOTAL'));
      expect(line, endsWith('3,500'));
    });

    test('keyValueText aligns the colon for every label', () {
      final member = service.keyValueText('Member Name', 'Faysal', 32);
      final id = service.keyValueText('Member ID', 'AG26U001', 32);

      expect(member, 'Member Name : Faysal');
      expect(id, 'Member ID   : AG26U001');
      expect(member.length, lessThanOrEqualTo(32));
      expect(id.length, lessThanOrEqualTo(32));
      expect(member.indexOf(':'), id.indexOf(':'));
    });

    test('keyValueText truncates long values instead of overflowing', () {
      final line = service.keyValueText(
        'Member Name',
        'A very long member name that cannot fit',
        32,
      );
      expect(line.length, 32);
    });

    test('separator fills exactly the paper width', () {
      expect(service.separator(32), '-' * 32);
      expect(service.separator(32, '='), '=' * 32);
      expect(service.separator(48), '-' * 48);
    });

    test('transactionRow keeps the 58mm row within 32 chars', () {
      final row = service.transactionRow(
        ReceiptTransaction(
          date: DateTime(2026, 9, 1),
          amount: 1000,
          paymentMethod: 'Cash Money',
        ),
        32,
      );
      expect(row, '01-09-2026     1,000  Cash Money');
      expect(row.length, 32);
    });
  });

  group('buildReceipt (58mm)', () {
    test('fits every line into 32 characters', () {
      final lines = service.buildReceiptLines(sampleReceipt());

      for (final line in lines) {
        expect(
          line.text.length <= ReceiptPaperSize.mm58.characters,
          isTrue,
          reason: 'line too long for 58mm: "${line.text}"',
        );
      }
    });

    test('contains member, month, transactions and formatted total', () {
      final text = String.fromCharCodes(
        service.buildReceipt(sampleReceipt()),
      );

      expect(text, contains(appOrganizationName));
      expect(text, contains(monthlyReceiptTitle));
      expect(text, contains('Faysal Hossain'));
      expect(text, contains('AG26U001'));
      expect(text, contains('September 2026'));
      expect(text, contains('01-09-2026'));
      expect(text, contains('10-09-2026'));
      expect(text, contains('20-09-2026'));
      expect(text, contains('Cash Money'));
      expect(text, contains('3,500'));
      expect(text, contains('Received By : Admin'));
      expect(text, contains('27-09-2026'));
      expect(text, contains('Thank You'));
    });

    test('bolds the title and the total, centers the header', () {
      final lines = service.buildReceiptLines(sampleReceipt());

      final orgLine = lines.firstWhere((l) => l.text == appOrganizationName);
      expect(orgLine.bold, isTrue);
      expect(orgLine.align, ReceiptAlign.center);

      final titleLine =
          lines.firstWhere((l) => l.text == monthlyReceiptTitle);
      expect(titleLine.bold, isTrue);
      expect(titleLine.align, ReceiptAlign.center);

      final totalLine = lines.firstWhere((l) => l.text.startsWith('TOTAL'));
      expect(totalLine.bold, isTrue);
      expect(totalLine.text, endsWith('3,500'));
    });

    test('starts with ESC @ reset and ends with feed + cut', () {
      final bytes = service.buildReceipt(sampleReceipt());

      expect(bytes[0], 0x1B); // ESC
      expect(bytes[1], 0x40); // @   - printer reset
      expect(
        bytes.sublist(bytes.length - 6),
        [0x1B, 0x64, 0x04, 0x1D, 0x56, 0x00],
        reason: 'ticket must end with feed (ESC d 4) then cut (GS V 0)',
      );
    });
  });

  group('buildReceipt (80mm)', () {
    test('fits long content into 48 characters', () {
      final wide = sampleReceipt();
      final lines = service.buildReceiptLines(
        ReceiptData(
          organizationName: wide.organizationName,
          title: wide.title,
          memberName: 'Md. Abdul Kadir Rahman Chowdhury',
          userId: wide.userId,
          monthLabel: wide.monthLabel,
          transactions: wide.transactions,
          total: 125000.5,
          receivedBy: wide.receivedBy,
          generatedAt: wide.generatedAt,
        ),
        paperSize: ReceiptPaperSize.mm80,
      );

      for (final line in lines) {
        expect(
          line.text.length <= ReceiptPaperSize.mm80.characters,
          isTrue,
          reason: 'line too long for 80mm: "${line.text}"',
        );
      }

      expect(
        String.fromCharCodes(
          service.buildReceipt(
            ReceiptData(
              organizationName: wide.organizationName,
              title: wide.title,
              memberName: 'Md. Abdul Kadir Rahman Chowdhury',
              userId: wide.userId,
              monthLabel: wide.monthLabel,
              transactions: wide.transactions,
              total: 125000.5,
              receivedBy: wide.receivedBy,
              generatedAt: wide.generatedAt,
            ),
            paperSize: ReceiptPaperSize.mm80,
          ),
        ),
        contains('125,000.50'),
      );
    });
  });

  group('printReceipt / printTest', () {
    test('printReceipt sends ESC/POS bytes to the printer', () async {
      final ok = await service.printReceipt(sampleReceipt());

      expect(ok, isTrue);
      expect(printer.lastBytes, isNotNull);
      expect(printer.lastBytes!.first, 0x1B);
      expect(printer.lastBytes![1], 0x40);
    });

    test('printReceipt forwards a printer failure', () async {
      printer.printResult = false;

      final ok = await service.printReceipt(sampleReceipt());

      expect(ok, isFalse);
      expect(printer.lastBytes, isNotNull);
    });

    test('test print contains the test marker', () {
      final text = String.fromCharCodes(service.buildTestPrint());

      expect(text, contains(appOrganizationName));
      expect(text, contains('TEST PRINT'));
      expect(text, contains('Printer connected successfully.'));
    });

    test('printTest sends bytes to the printer', () async {
      final ok = await service.printTest();

      expect(ok, isTrue);
      expect(
        String.fromCharCodes(printer.lastBytes!),
        contains('TEST PRINT'),
      );
    });
  });
}
