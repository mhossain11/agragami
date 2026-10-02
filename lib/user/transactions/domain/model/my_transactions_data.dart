import '../../../money record/domain/model/money_record.dart';

/// Profile + every money record of the member who is signed in right now.
///
/// Nothing here ever comes from user input: the repository fills it from
/// the Firebase Auth session (see `MyTransactionsRepository`), so the PDF
/// can only ever contain the logged-in member's own data.
class MyTransactionsData {
  const MyTransactionsData({
    required this.name,
    required this.userId,
    required this.email,
    required this.phone,
    required this.transactions,
  });

  /// `name` of `users/{uid}`.
  final String name;

  /// `user_id` of `users/{uid}` (the member ID shown in the app).
  final String userId;

  /// `email` of `users/{uid}`.
  final String email;

  /// `phone` of `users/{uid}`.
  final String phone;

  /// The member's own `Money` records, newest first - see
  /// [sortTransactionsNewestFirst].
  final List<MoneyRecord> transactions;

  /// Sum of every transaction amount.
  double get totalTransactionAmount {
    var total = 0.0;
    for (final record in transactions) {
      total += record.amount;
    }
    return total;
  }

  /// How many transactions the member has made.
  int get totalTransactionCount => transactions.length;

  /// Total money the somiti has collected from this member - every
  /// payment added up (the `amount` field of each `Money` record).
  double get totalCollectedAmount => totalTransactionAmount;
}

/// Sorts money records by `date&time` descending (newest first) - the
/// order required for the transaction statement. Records without a
/// usable date go last instead of being dropped, so the statement always
/// shows the complete history.
void sortTransactionsNewestFirst(List<MoneyRecord> records) {
  records.sort((a, b) {
    final aDate = a.dateTime ?? a.collectionDate;
    final bDate = b.dateTime ?? b.collectionDate;
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return bDate.compareTo(aDate);
  });
}
