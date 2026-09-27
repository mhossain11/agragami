import '../model/receipt_data.dart';
import 'thermal_printer_service.dart';

/// Horizontal position of a receipt line on paper.
enum ReceiptAlign { left, center }

/// One formatted line of a receipt ticket.
class ReceiptLine {
  const ReceiptLine(
    this.text, {
    this.align = ReceiptAlign.left,
    this.bold = false,
  });

  final String text;
  final ReceiptAlign align;
  final bool bold;
}

/// Builds real ESC/POS byte tickets from [ReceiptData] and sends them
/// through a [ThermalPrinterService].
///
/// All paper-width formatting lives here (single source of truth), so the
/// controller, widgets and tests share the exact same helpers:
/// [centerText], [leftRightText], [keyValueText], [separator],
/// [formatAmount], [formatDate], [transactionRow] and [buildReceipt].
class ReceiptPrintService {
  ReceiptPrintService(this._printer);

  final ThermalPrinterService _printer;

  // ------------------------------------------------------------------
  // ESC/POS commands
  // ------------------------------------------------------------------
  static const List<int> _cmdInit = [0x1B, 0x40]; // ESC @    reset
  static const List<int> _cmdAlignLeft = [0x1B, 0x61, 0x00]; // ESC a 0
  static const List<int> _cmdAlignCenter = [0x1B, 0x61, 0x01]; // ESC a 1
  static const List<int> _cmdBoldOn = [0x1B, 0x45, 0x01]; // ESC E 1
  static const List<int> _cmdBoldOff = [0x1B, 0x45, 0x00]; // ESC E 0
  static const List<int> _cmdFeed = [0x1B, 0x64, 0x04]; // ESC d 4  feed 4
  static const List<int> _cmdCut = [0x1D, 0x56, 0x00]; // GS V 0   full cut

  // ------------------------------------------------------------------
  // Formatting helpers
  // ------------------------------------------------------------------

  /// `1000` -> `1,000` · `15000` -> `15,000` · `125000.5` -> `125,000.50`
  String formatAmount(num amount) {
    final negative = amount < 0;
    final parts = amount.abs().toStringAsFixed(2).split('.');
    final digits = parts[0];

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }

    final hasCents = parts[1] != '00';
    final result = buffer.toString() + (hasCents ? '.${parts[1]}' : '');
    return negative ? '-$result' : result;
  }

  /// `2026-09-27` -> `27-09-2026`
  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  /// Centers [text] inside a [width] character line.
  String centerText(String text, int width) {
    final content = _fit(text, width);
    final padding = width - content.length;
    if (padding <= 0) return content;
    final left = padding ~/ 2;
    return '${' ' * left}$content${' ' * (padding - left)}';
  }

  /// Puts [left] at the start and [right] at the end of a [width] row.
  String leftRightText(String left, String right, int width) {
    if (left.length + right.length >= width) {
      final rightPart = _fit(right, width);
      final leftPart = _fit(left, width - rightPart.length);
      return '$leftPart${' ' * (width - leftPart.length - rightPart.length)}'
          '$rightPart';
    }
    return '$left${' ' * (width - left.length - right.length)}$right';
  }

  /// `Member Name : Faysal Hossain` style row, always exactly [width].
  /// Labels are padded to 12 chars so every colon lands on one column.
  String keyValueText(String label, String value, int width) {
    final prefix = '${label.padRight(12)}: ';
    final budget = width - prefix.length;
    if (budget <= 0) return _fit(prefix, width);
    return prefix + _fit(value, budget);
  }

  /// A full [width] run of [char] (default `-`).
  String separator(int width, [String char = '-']) {
    if (char.isEmpty || width <= 0) return '';
    return char.substring(0, 1) * width;
  }

  /// One transaction table row:
  /// `01-09-2026     1,000  Cash Money`
  String transactionRow(ReceiptTransaction transaction, int width) =>
      transactionRowValues(
        formatDate(transaction.date),
        formatAmount(transaction.amount),
        transaction.paymentMethod,
        width,
      );

  /// Same row layout but with pre-formatted [date] / [amount] strings
  /// (also used for the `Date  Amount  Method` header row).
  String transactionRowValues(
    String date,
    String amount,
    String method,
    int width,
  ) {
    const gap = 2;
    // 10 (date) + 2 + 8 (amount) + 2 + 10 (e.g. "Cash Money") = 32 chars
    const amountColumn = 8;

    final paddedDate = date.padRight(10);
    final paddedAmount =
        amount.length >= amountColumn ? amount : amount.padLeft(amountColumn);

    var row = '$paddedDate  $paddedAmount';
    if (method.isNotEmpty) {
      final remaining = width - row.length - gap;
      if (remaining > 0) {
        row = '$row  ${_fit(method, remaining)}';
      }
    }
    return _fit(row, width);
  }

  // ------------------------------------------------------------------
  // Receipt building
  // ------------------------------------------------------------------

  /// Every printed line of the receipt (text + alignment + bold).
  List<ReceiptLine> buildReceiptLines(
    ReceiptData data, {
    ReceiptPaperSize paperSize = ReceiptPaperSize.mm58,
  }) {
    final width = paperSize.characters;
    final lines = <ReceiptLine>[];

    void add(
      String text, {
      ReceiptAlign align = ReceiptAlign.left,
      bool bold = false,
    }) {
      lines.add(ReceiptLine(_fit(text, width), align: align, bold: bold));
    }

    // ----- header -----
    add(separator(width, '='), align: ReceiptAlign.center);
    add(data.organizationName, align: ReceiptAlign.center, bold: true);
    add(data.title, align: ReceiptAlign.center, bold: true);
    add(separator(width, '='));

    // ----- member block -----
    add('');
    add(keyValueText('Member Name', data.memberName, width));
    add(keyValueText('Member ID', data.userId, width));
    add(keyValueText('Month', data.monthLabel, width));

    // ----- transactions -----
    add(separator(width));
    add(transactionRowValues('Date', 'Amount', 'Method', width));

    for (final transaction in data.transactions) {
      add(transactionRow(transaction, width));
    }

    add(separator(width));
    add(leftRightText('TOTAL', formatAmount(data.total), width), bold: true);
    add(separator(width, '='));

    // ----- footer -----
    add('');
    if (data.receivedBy.isNotEmpty) {
      add(keyValueText('Received By', data.receivedBy, width));
    }
    add(keyValueText('Date', formatDate(data.generatedAt), width));
    add('');
    add('Thank You', align: ReceiptAlign.center);
    add(data.organizationName, align: ReceiptAlign.center);
    add(separator(width, '='), align: ReceiptAlign.center);

    return lines;
  }

  /// Raw ESC/POS bytes for the monthly money receipt.
  List<int> buildReceipt(
    ReceiptData data, {
    ReceiptPaperSize paperSize = ReceiptPaperSize.mm58,
  }) =>
      _ticketFromLines(buildReceiptLines(data, paperSize: paperSize));

  /// Raw ESC/POS bytes for a small connection test ticket.
  List<int> buildTestPrint({
    String organizationName = appOrganizationName,
    ReceiptPaperSize paperSize = ReceiptPaperSize.mm58,
  }) {
    final width = paperSize.characters;
    final lines = <ReceiptLine>[
      ReceiptLine(separator(width, '='), align: ReceiptAlign.center),
      ReceiptLine(organizationName, align: ReceiptAlign.center, bold: true),
      ReceiptLine('TEST PRINT', align: ReceiptAlign.center, bold: true),
      ReceiptLine(separator(width, '=')),
      const ReceiptLine(''),
      const ReceiptLine('Printer connected successfully.'),
      const ReceiptLine(''),
      ReceiptLine(keyValueText('Date', formatDate(DateTime.now()), width)),
      const ReceiptLine(''),
      ReceiptLine(separator(width, '='), align: ReceiptAlign.center),
    ];
    return _ticketFromLines(lines);
  }

  /// Sends the monthly receipt to the connected printer.
  Future<bool> printReceipt(
    ReceiptData data, {
    ReceiptPaperSize paperSize = ReceiptPaperSize.mm58,
  }) =>
      _printer.printBytes(buildReceipt(data, paperSize: paperSize));

  /// Sends a test ticket to the connected printer.
  Future<bool> printTest({ReceiptPaperSize paperSize = ReceiptPaperSize.mm58}) =>
      _printer.printBytes(buildTestPrint(paperSize: paperSize));

  // ------------------------------------------------------------------
  // Internals
  // ------------------------------------------------------------------

  List<int> _ticketFromLines(List<ReceiptLine> lines) {
    final bytes = <int>[];
    bytes.addAll(_cmdInit);

    var align = ReceiptAlign.left;
    var bold = false;

    for (final line in lines) {
      if (line.align != align) {
        align = line.align;
        bytes.addAll(
          align == ReceiptAlign.center ? _cmdAlignCenter : _cmdAlignLeft,
        );
      }
      if (line.bold != bold) {
        bold = line.bold;
        bytes.addAll(bold ? _cmdBoldOn : _cmdBoldOff);
      }
      bytes.addAll(line.text.codeUnits);
      bytes.add(0x0A); // LF - print the line
    }

    if (bold) bytes.addAll(_cmdBoldOff);
    bytes.addAll(_cmdFeed);
    bytes.addAll(_cmdCut);
    return bytes;
  }

  String _fit(String text, int width) {
    if (width <= 0) return '';
    return text.length <= width ? text : text.substring(0, width);
  }
}
