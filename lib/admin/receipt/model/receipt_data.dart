/// App / organisation name printed on receipts.
/// Matches the app name (`android:label` + pubspec `name`).
const String appOrganizationName = 'Agragami';

/// Title printed under the organisation name.
const String monthlyReceiptTitle = 'MONTHLY INSTALMENT RECEIPT';

/// Collection type shown on every monthly receipt.
const String monthlyCollectionType = 'Monthly Instalment';

/// Remarks line shown on every monthly receipt.
const String monthlyReceiptRemarks = 'Monthly Collection';

/// Supported thermal paper widths.
///
/// [characters] is the usable character count per line, tuned for the
/// default font size of common ESC/POS printers.
enum ReceiptPaperSize {
  mm58(32),
  mm80(48);

  const ReceiptPaperSize(this.characters);

  final int characters;
}

/// One money line of the receipt (`users/{id}/Money` document).
class ReceiptTransaction {
  const ReceiptTransaction({
    required this.date,
    required this.amount,
    this.paymentMethod = '',
  });

  final DateTime date;
  final double amount;
  final String paymentMethod;
}

/// Everything the printer needs to render a receipt.
///
/// The optional fields are printed only when they are not empty, so older
/// call sites (and tests) that do not provide them keep working.
class ReceiptData {
  const ReceiptData({
    required this.organizationName,
    required this.title,
    required this.memberName,
    required this.userId,
    required this.monthLabel,
    required this.transactions,
    required this.total,
    required this.receivedBy,
    required this.generatedAt,
    this.receiptNo = '',
    this.instalmentNo = '',
    this.collectionType = '',
    this.paymentMode = '',
    this.remarks = '',
    this.instalmentMonths = 0,
  });

  final String organizationName;
  final String title;
  final String memberName;
  final String userId;
  final String monthLabel;
  final List<ReceiptTransaction> transactions;
  final double total;
  final String receivedBy;
  final DateTime generatedAt;

  /// `RC-2609-001` - see [buildReceiptNo].
  final String receiptNo;

  /// `01`, `02`, ... - see [buildInstalmentNo].
  final String instalmentNo;

  /// `Monthly Instalment` - [monthlyCollectionType].
  final String collectionType;

  /// `Cash` / `Various` - see [buildPaymentMode].
  final String paymentMode;

  /// `Monthly Collection` - [monthlyReceiptRemarks].
  final String remarks;

  /// Total instalment months, calculated from the member's existing money
  /// records (distinct months with at least one record). Never stored in
  /// the database - printed as `Instalment Month: 6 months` via
  /// [buildInstalmentMonthsLabel].
  final int instalmentMonths;
}

// --------------------------------------------------------------------------
// Receipt metadata helpers (pure functions - easy to test)
// --------------------------------------------------------------------------

/// Receipt number: `RC-YYMM-SSS`.
///
/// * `YYMM` = year + month the receipt was issued (`2026-09` -> `2609`)
/// * `SSS`  = member serial = last three digits of the user id
///   (`AG26U001` -> `001`)
///
/// One member can only get one monthly receipt, so this number is unique
/// per member per month.
String buildReceiptNo(String userId, DateTime issuedAt) {
  final yy = (issuedAt.year % 100).toString().padLeft(2, '0');
  final mm = issuedAt.month.toString().padLeft(2, '0');

  final digits = userId.replaceAll(RegExp(r'\D'), '');
  final serial = digits.length >= 3
      ? digits.substring(digits.length - 3)
      : digits.padLeft(3, '0');

  return 'RC-$yy$mm-$serial';
}

/// Instalment number: how many instalments were recorded this month.
String buildInstalmentNo(int instalmentCount) =>
    instalmentCount.toString().padLeft(2, '0');

/// Instalment month count label: `6 months`, `1 month` (singular) or
/// `0 months` - the value shown for `Instalment Month`.
String buildInstalmentMonthsLabel(int months) =>
    '$months month${months == 1 ? '' : 's'}';

/// Payment mode: the single method used this month, or `Various` when the
/// member paid with more than one method. Empty methods are ignored.
String buildPaymentMode(Iterable<String> methods) {
  final unique = <String>{};

  for (final method in methods) {
    final trimmed = method.trim();
    if (trimmed.isNotEmpty) unique.add(trimmed);
  }

  if (unique.isEmpty) return '';
  if (unique.length == 1) return unique.first;
  return 'Various';
}
