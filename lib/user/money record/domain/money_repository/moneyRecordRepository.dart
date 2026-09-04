import '../model/money_record.dart';

abstract class MoneyRecordRepository {

  Future<String> getCachedUserDocId();

  Stream<List<MoneyRecord>> watchMoneyRecords(String userDocId);
}