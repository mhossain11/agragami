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

/// Index of [needle] in [hay], or -1 when it does not occur.
int indexOfSeq(List<int> hay, List<int> needle, {bool fromEnd = false}) {
  for (var i = 0; i + needle.length <= hay.length; i++) {
    final start = fromEnd ? hay.length - i - needle.length : i;
    var match = true;
    for (var j = 0; j < needle.length; j++) {
      if (hay[start + j] != needle[j]) {
        match = false;
        break;
      }
    }
    if (match) return start;
  }
  return -1;
}

/// True when [needle] occurs anywhere in [hay].
bool containsSequence(List<int> hay, List<int> needle) =>
    indexOfSeq(hay, needle) != -1;

ReceiptData sampleReceipt() => ReceiptData(
      organizationName: appOrganizationName,
      title: monthlyReceiptTitle,
      memberName: 'Faysal Hossain',
      userId: 'AG26U001',
      monthLabel: 'September 2026',
      receiptNo: buildReceiptNo('AG26U001', DateTime(2026, 9, 27)),
      instalmentNo: buildInstalmentNo(3),
      collectionType: monthlyCollectionType,
      paymentMode: buildPaymentMode(const ['Cash Money', 'Bank', 'Bkash']),
      remarks: monthlyReceiptRemarks,
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

/// Same receipt without the optional metadata fields.
ReceiptData bareReceipt() => ReceiptData(
      organizationName: appOrganizationName,
      title: monthlyReceiptTitle,
      memberName: 'Faysal Hossain',
      userId: 'AG26U001',
      monthLabel: 'September 2026',
      transactions: [
        ReceiptTransaction(date: DateTime(2026, 9, 1), amount: 500),
      ],
      total: 500,
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

    test('leftRightText drops the left side instead of overflowing', () {
      final line = service.leftRightText('TOTAL', 'A' * 40, 32);
      expect(line.length, 32);
      expect(line, startsWith('A'));
    });

    test('keyValueText aligns the colon on column 16 for every label', () {
      final member = service.keyValueText('Member Name', 'Faysal', 32);
      final id = service.keyValueText('Member ID', 'AG26U001', 32);
      final month = service.keyValueText('Instalment Month', 'Sep', 32);

      expect(member, 'Member Name     : Faysal');
      expect(id, 'Member ID       : AG26U001');
      expect(month, 'Instalment Month: Sep');
      expect(member.length, lessThanOrEqualTo(32));
      expect(member.indexOf(':'), 16);
      expect(id.indexOf(':'), 16);
      expect(month.indexOf(':'), 16);
    });

    test('keyValueText truncates long values instead of overflowing', () {
      final line = service.keyValueText(
        'Member Name',
        'A very long member name that cannot fit',
        32,
      );
      expect(line.length, 32);
    });

    test('keyValueLines keeps a fitting value on a single line', () {
      final rows = service.keyValueLines('Receipt No.', 'RC-2609-001', 32);

      expect(rows, hasLength(1));
      expect(rows.single, 'Receipt No.     : RC-2609-001');
    });

    test('keyValueLines moves a long value to an indented second line', () {
      final rows =
          service.keyValueLines('Collection Type', 'Monthly Instalment', 32);

      expect(rows, hasLength(2));
      expect(rows[0], 'Collection Type :');
      expect(rows[1], '  Monthly Instalment');
      for (final row in rows) {
        expect(row.length <= 32, isTrue, reason: 'too long: "$row"');
      }
    });

    test('keyValueLines never exceeds the paper for any value', () {
      final rows = service.keyValueLines('Member Name', 'X' * 80, 32);

      expect(rows, hasLength(2));
      for (final row in rows) {
        expect(row.length <= 32, isTrue, reason: 'too long: "$row"');
      }
    });

    test('separator fills exactly the paper width', () {
      expect(service.separator(32), '-' * 32);
      expect(service.separator(32, '='), '=' * 32);
      expect(service.separator(48), '-' * 48);
    });

    test('boldText marks the line bold and fits the width', () {
      final line = service.boldText('A' * 40, 32);

      expect(line.bold, isTrue);
      expect(line.align, ReceiptAlign.left);
      expect(line.text.length, 32);
    });

    test('doubleText uses double size when the text fits half width', () {
      final line = service.doubleText('Tk. 1,000', 32);

      expect(line.size, ReceiptSize.double);
      expect(line.bold, isTrue);
      expect(line.text.length, lessThanOrEqualTo(16));
    });

    test('doubleText falls back to a normal bold line when too long', () {
      final line = service.doubleText('A' * 20, 32);

      expect(line.size, ReceiptSize.normal);
      expect(line.bold, isTrue);
      expect(line.text.length, 20);
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

  group('receipt metadata helpers', () {
    test('buildReceiptNo combines issue month and member serial', () {
      expect(
        buildReceiptNo('AG26U001', DateTime(2026, 9, 27)),
        'RC-2609-001',
      );
      expect(buildReceiptNo('AG26U001', DateTime(2026, 10, 1)), 'RC-2610-001');
    });

    test('buildReceiptNo tolerates ids without digits', () {
      expect(buildReceiptNo('AB12', DateTime(2026, 9, 27)), 'RC-2609-012');
      expect(buildReceiptNo('XYZ', DateTime(2026, 9, 27)), 'RC-2609-000');
      expect(buildReceiptNo('', DateTime(2026, 9, 27)), 'RC-2609-000');
    });

    test('buildInstalmentNo pads to two digits', () {
      expect(buildInstalmentNo(1), '01');
      expect(buildInstalmentNo(12), '12');
    });

    test('buildPaymentMode reports the single method or Various', () {
      expect(buildPaymentMode(const []), '');
      expect(buildPaymentMode(const ['', ' ']), '');
      expect(buildPaymentMode(const ['Cash', 'Cash']), 'Cash');
      expect(buildPaymentMode(const [' Cash ']), 'Cash');
      expect(buildPaymentMode(const ['Cash', 'bKash']), 'Various');
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

      expect(text, contains(appOrganizationName.toUpperCase()));
      expect(text, contains(monthlyReceiptTitle));
      expect(text, contains('Faysal Hossain'));
      expect(text, contains('AG26U001'));
      expect(text, contains('September 2026'));
      expect(text, contains('01-09-2026'));
      expect(text, contains('10-09-2026'));
      expect(text, contains('20-09-2026'));
      expect(text, contains('Cash Money'));
      expect(text, contains('3,500'));
      expect(text, contains('Received By     : Admin'));
      expect(text, contains('27-09-2026'));
      expect(text, contains('Thank You'));
    });

    test('contains every receipt metadata field of the new design', () {
      final text = String.fromCharCodes(
        service.buildReceipt(sampleReceipt()),
      );

      expect(text, contains('Receipt No.     : RC-2609-001'));
      expect(text, contains('Receipt Date    : 27-09-2026'));
      expect(text, contains('Instalment No.  : 03'));
      expect(text, contains('Collection Type :'));
      expect(text, contains('Monthly Instalment'));
      expect(text, contains('Payment Mode    : Various'));
      expect(text, contains('Monthly Collection'));
      expect(text, contains('AMOUNT'));
      expect(text, contains('Thank You For Your Payment'));
      expect(text, contains('System Generated Receipt'));
      expect(text, contains('No Signature Required'));
    });

    test('skips optional metadata lines when the fields are empty', () {
      final text = String.fromCharCodes(
        service.buildReceipt(bareReceipt()),
      );

      expect(text, isNot(contains('Receipt No.')));
      expect(text, isNot(contains('Instalment No.')));
      expect(text, isNot(contains('Collection Type')));
      expect(text, isNot(contains('Payment Mode')));
      expect(text, isNot(contains('Remarks')));
      expect(text, contains('Receipt Date'));
    });

    test('bolds the title and the amount, centers the header', () {
      final lines = service.buildReceiptLines(sampleReceipt());

      final orgLine = lines
          .firstWhere((l) => l.text == appOrganizationName.toUpperCase());
      expect(orgLine.bold, isTrue);
      expect(orgLine.align, ReceiptAlign.center);
      expect(orgLine.size, ReceiptSize.double);

      final titleLine =
          lines.firstWhere((l) => l.text == monthlyReceiptTitle);
      expect(titleLine.bold, isTrue);
      expect(titleLine.align, ReceiptAlign.center);

      final amountLabel = lines.firstWhere((l) => l.text.trim() == 'AMOUNT');
      expect(amountLabel.bold, isTrue);
      expect(amountLabel.align, ReceiptAlign.center);

      final totalLine = lines.firstWhere((l) => l.text.startsWith('TOTAL'));
      expect(totalLine.bold, isTrue);
      expect(totalLine.text, endsWith('3,500'));
      expect(totalLine.size, ReceiptSize.double);
    });

    test('uses GS ! double-size around the big lines only', () {
      final bytes = service.buildReceipt(sampleReceipt());

      // GS ! 03 = double width + height ... GS ! 00 = back to normal.
      expect(containsSequence(bytes, [0x1D, 0x21, 0x03]), isTrue);
      expect(containsSequence(bytes, [0x1D, 0x21, 0x00]), isTrue);

      // Size is always reset to normal before feed (ESC d 4).
      final resetIndex =
          indexOfSeq(bytes, const [0x1D, 0x21, 0x00], fromEnd: true);
      final feedIndex = indexOfSeq(bytes, const [0x1B, 0x64, 0x04]);
      expect(resetIndex, greaterThanOrEqualTo(0));
      expect(resetIndex, lessThan(feedIndex));
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

    test('prints the organisation name as a double-size line', () {
      final bytes = service.buildReceipt(sampleReceipt());

      // GS ! 03 (double size) immediately followed by the organisation
      // name and LF - this is what appears at the top of the paper.
      final expected = <int>[
        0x1D,
        0x21,
        0x03,
        ...appOrganizationName.toUpperCase().codeUnits,
        0x0A,
      ];
      expect(
        containsSequence(bytes, expected),
        isTrue,
        reason: 'the organisation name must be part of the printed ticket',
      );
    });

    test('starts with the organisation name (nothing above it)', () {
      final lines = service.buildReceiptLines(sampleReceipt());

      expect(lines.first.text, appOrganizationName.toUpperCase());
      expect(lines.first.size, ReceiptSize.double);
      expect(lines.first.align, ReceiptAlign.center);

      // The title follows directly, then the strong rule.
      expect(lines[1].text, monthlyReceiptTitle);
    });
  });

  group('buildReceipt (80mm)', () {
    test('fits long content into 48 characters', () {
      final wide = sampleReceipt();
      final data = ReceiptData(
        organizationName: wide.organizationName,
        title: wide.title,
        memberName: 'Md. Abdul Kadir Rahman Chowdhury',
        userId: wide.userId,
        monthLabel: wide.monthLabel,
        transactions: wide.transactions,
        total: 125000.5,
        receivedBy: wide.receivedBy,
        generatedAt: wide.generatedAt,
      );

      final lines = service.buildReceiptLines(
        data,
        paperSize: ReceiptPaperSize.mm80,
      );

      for (final line in lines) {
        expect(
          line.text.length <= ReceiptPaperSize.mm80.characters,
          isTrue,
          reason: 'line too long for 80mm: "${line.text}"',
        );
      }

      final text = String.fromCharCodes(
        service.buildReceipt(
          data,
          paperSize: ReceiptPaperSize.mm80,
        ),
      );
      expect(text, contains('125,000.50'));
      expect(text, contains('Md. Abdul Kadir Rahman Chowdhury'));
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
