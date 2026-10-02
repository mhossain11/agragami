import '../model/my_transactions_data.dart';

/// Loads everything the "My Transactions" PDF needs.
///
/// The member is identified from the Firebase Auth session inside the
/// implementation - callers can never pass a user id, so no screen can
/// ask for another member's data.
abstract class MyTransactionsRepository {
  Future<MyTransactionsData> loadMyTransactions();
}
