import '../model/receipt_data.dart';
import 'thermal_printer_service.dart';

/// Horizontal position of a receipt line on paper.
enum ReceiptAlign { left, center }

/// Character size of a receipt line (ESC/POS `GS !`).
///
/// [ReceiptSize.double] prints at double width + double height - used for
/// the organisation name and the amount so they stand out.
enum ReceiptSize { normal, double }

/// One formatted line of a receipt ticket.
class ReceiptLine {
  const ReceiptLine(
    this.text, {
    this.align = ReceiptAlign.left,
    this.bold = false,
    this.size = ReceiptSize.normal,
  });

  final String text;
  final ReceiptAlign align;
  final bool bold;
  final ReceiptSize size;
}

/// Builds real ESC/POS byte tickets from [ReceiptData] and sends them
/// through a [ThermalPrinterService].
///
/// All paper-width formatting lives here (single source of truth), so the
/// controller, widgets and tests share the exact same helpers:
/// [centerText], [leftRightText], [keyValueText], [keyValueLines],
/// [separator], [boldText], [doubleText], [formatAmount], [formatDate],
/// [transactionRow] and [buildReceiptLines].
class ReceiptPrintService {
  ReceiptPrintService(this._printer);

  final ThermalPrinterService _printer;

  /// Label column width: every `label : value` colon lands on column 16,
  /// so all rows stay aligned no matter how long the label is.
  static const int _labelColumn = 16;

  // ------------------------------------------------------------------
  // ESC/POS commands
  // ------------------------------------------------------------------
  static const List<int> _cmdInit = [0x1B, 0x40]; // ESC @    reset
  static const List<int> _cmdAlignLeft = [0x1B, 0x61, 0x00]; // ESC a 0
  static const List<int> _cmdAlignCenter = [0x1B, 0x61, 0x01]; // ESC a 1
  static const List<int> _cmdBoldOn = [0x1B, 0x45, 0x01]; // ESC E 1
  static const List<int> _cmdBoldOff = [0x1B, 0x45, 0x00]; // ESC E 0
  static const List<int> _cmdSizeDouble = [0x1D, 0x21, 0x03]; // GS ! 3  W+H x2
  static const List<int> _cmdSizeNormal = [0x1D, 0x21, 0x00]; // GS ! 0  normal
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
  /// Labels are padded to 16 chars so every colon lands on one column.
  String keyValueText(String label, String value, int width) {
    final prefix = '${label.padRight(_labelColumn)}: ';
    final budget = width - prefix.length;
    if (budget <= 0) return _fit(prefix, width);
    return prefix + _fit(value, budget);
  }

  /// Same as [keyValueText] but returns one **or two** lines: when the
  /// value does not fit next to the label it continues on the next line
  /// (indented), so no information is ever truncated. Long single words
  /// are still cut to [width] so nothing can overflow the paper.
  List<String> keyValueLines(String label, String value, int width) {
    final prefix = '${label.padRight(_labelColumn)}: ';
    final budget = width - prefix.length;

    if (budget > 0 && value.length <= budget) {
      return [prefix + value];
    }

    // Value continues on its own indented line so nothing is lost.
    const indent = 2;
    final labelLine = _fit('${label.padRight(_labelColumn)}:'.trimRight(), width);
    return [labelLine, _fit(' ' * indent + value, width)];
  }

  /// A full [width] run of [char] (default `-`).
  String separator(int width, [String char = '-']) {
    if (char.isEmpty || width <= 0) return '';
    return char.substring(0, 1) * width;
  }

  /// A bold line (ESC/POS emphasis), fitted to [width].
  ReceiptLine boldText(
    String text,
    int width, {
    ReceiptAlign align = ReceiptAlign.left,
  }) =>
      ReceiptLine(_fit(text, width), align: align, bold: true);

  /// A big, bold line (double width + double height, ESC/POS `GS ! 03`).
  ///
  /// Double-size characters take two paper cells, so the text is limited to
  /// `width / 2` characters - longer text falls back to a normal-size bold
  /// line instead of breaking the layout.
  ReceiptLine doubleText(
    String text,
    int width, {
    ReceiptAlign align = ReceiptAlign.center,
  }) {
    final half = width ~/ 2;
    if (_fit(text, width).length <= half) {
      return ReceiptLine(
        _fit(text, half),
        align: align,
        bold: true,
        size: ReceiptSize.double,
      );
    }
    return ReceiptLine(_fit(text, width), align: align, bold: true);
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
    const dateColumn = 10;
    const amountColumn = 8;
    const methodColumn = 10;
    const gap = 2;

    final paddedDate = date.padRight(dateColumn);
    final paddedAmount = amount.length >= amountColumn
        ? amount
        : amount.padLeft(amountColumn);

    final paddedMethod = method.length >= methodColumn
        ? _fit(method, methodColumn)
        : method.padRight(methodColumn);

    final row =
        '$paddedDate'
        '${' ' * gap}'
        '$paddedAmount'
        '${' ' * gap}'
        '$paddedMethod';

    return _fit(row, width);
  }

  // ------------------------------------------------------------------
  // Receipt building
  // ------------------------------------------------------------------

  /// Every printed line of the receipt (text + alignment + bold + size).
  ///
  /// Structure (58 mm = 32 chars, 80 mm = 48 chars):
  ///
  /// ```text
  ///            AGRAGAMI             <- double size (first line)
  ///    MONTHLY INSTALMENT RECEIPT   <- bold
  /// ================================
  /// Receipt No.     : RC-2609-001   <- receipt info block
  /// Receipt Date    : 27-09-2026
  /// --------------------------------
  /// Member ID       : AG26U001      <- member block
  /// Member Name     : Faysal Hossain
  /// --------------------------------
  /// Instalment Month: 6 months    <- distinct months with records
  /// Instalment No.  : 01            <- instalment block
  /// Collection Type :
  ///   Monthly Instalment
  /// --------------------------------
  /// Date        Amount  Method      <- transactions
  /// 01-09-2026     1,000  Cash
  /// --------------------------------
  ///              AMOUNT             <- bold
  /// TOTAL  Tk. 1,000                <- double size (prominent)
  /// ================================
  /// Payment Mode    : Cash          <- payment block
  /// Received By     : Admin
  /// Remarks         :
  ///   Monthly Collection
  ///
  ///       Thank You For Your Payment
  /// --------------------------------
  ///   System Generated Receipt      <- professional footer
  ///     No Signature Required
  /// ================================
  /// ```
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

    void addKv(String label, String value) {
      for (final row in keyValueLines(label, value, width)) {
        add(row);
      }
    }

    // ----- header: the ticket starts with the organisation name -----
    lines.add(boldText(data.organizationName.toUpperCase(), width, align: ReceiptAlign.center));
    lines.add(boldText(data.title, width, align: ReceiptAlign.center));
    add(separator(width, '='), align: ReceiptAlign.center);

    // ----- receipt info -----
    if (data.receiptNo.isNotEmpty) {
      addKv('Receipt No.', data.receiptNo);
    }
    addKv('Receipt Date', formatDate(data.generatedAt));

    // ----- member -----
    add(separator(width));
    addKv('Member ID', data.userId);
    addKv('Member Name', data.memberName);

    // ----- instalment -----
    add(separator(width));
    if (data.instalmentNo.isNotEmpty) {
      addKv('Instalment No.', buildInstalmentMonthsLabel(data.instalmentMonths));
    }
    addKv('Month', data.monthLabel);



    // ----- transactions -----
    add(separator(width));
    add(transactionRowValues('Date', 'Amount', ' Method', width));

    for (final transaction in data.transactions) {
      add(transactionRow(transaction, width));
    }

    // ----- amount (the hero of the receipt) -----
    add(separator(width));
    lines.add(
      boldText(centerText('AMOUNT', width), width, align: ReceiptAlign.center),
    );
    lines.add(
      boldText(
        leftRightText('TOTAL', 'Tk. ${formatAmount(data.total)}', width ~/ 2),
        width,align: ReceiptAlign.center
      ),
    );
    add(separator(width, '='), align: ReceiptAlign.center);

    // ----- payment info -----
   /* if (data.paymentMode.isNotEmpty) {
      addKv('Payment Mode', data.paymentMode);
    }*/
    if (data.collectionType.isNotEmpty) {
      addKv('Collection', data.collectionType);
    }
    if (data.receivedBy.isNotEmpty) {
      addKv('Received By', data.receivedBy);
    }

    /*if (data.remarks.isNotEmpty) {
      addKv('Remarks', data.remarks);
    }*/

    // ----- footer -----
    add('');
    add(
      centerText('Thank You For Your Payment', width),
      align: ReceiptAlign.center,
    );
    add(separator(width));
    add(
      centerText('System Generated Receipt', width),
      align: ReceiptAlign.center,
    );
    add(
      centerText('No Signature Required', width),
      align: ReceiptAlign.center,
    );
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
    var size = ReceiptSize.normal;

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
      if (line.size != size) {
        size = line.size;
        bytes.addAll(size == ReceiptSize.double ? _cmdSizeDouble : _cmdSizeNormal);
      }
      bytes.addAll(line.text.codeUnits);
      bytes.add(0x0A); // LF - print the line
    }

    // Always leave the printer in its normal state before feed + cut.
    if (size != ReceiptSize.normal) bytes.addAll(_cmdSizeNormal);
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
