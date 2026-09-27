import '../model/money_record.dart';

abstract class MoneyRecordRepository {

  Future<String> getCachedUserDocId();

  Stream<List<MoneyRecord>> watchMoneyRecords(String userDocId);

  /// One month's money records for a single member
  /// (`users/{userDocId}/Money`), sorted by transaction date ascending.
  Future<List<MoneyRecord>> getMonthlyMoneyRecords({
    required String userDocId,
    required DateTime month,
  });
}