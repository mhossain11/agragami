/// App / organisation name printed on receipts.
/// Matches the app name (`android:label` + pubspec `name`).
const String appOrganizationName = 'Agragami';

/// Title printed under the organisation name.
const String monthlyReceiptTitle = 'MONTHLY INSTALMENT RECEIPT';

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
}
