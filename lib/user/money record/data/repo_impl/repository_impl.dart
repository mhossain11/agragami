import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/cachehelper/chechehelper.dart';
import '../../domain/model/money_record.dart';
import '../../domain/money_repository/moneyRecordRepository.dart';

class MoneyRecordRepositoryImpl implements MoneyRecordRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> getCachedUserDocId() async {
    return CacheHelper().getString('userDocId') ?? '';
  }

  @override
  Stream<List<MoneyRecord>> watchMoneyRecords(String userDocId) {
    if (userDocId.isEmpty) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(userDocId)
        .collection('Money')
        .orderBy('date&time', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map(MoneyRecord.fromDoc).toList());
  }

  @override
  Future<List<MoneyRecord>> getMonthlyMoneyRecords({
    required String userDocId,
    required DateTime month,
  }) async {
    if (userDocId.isEmpty) return const [];

    final startOfMonth = DateTime(month.year, month.month, 1);
    final startOfNextMonth = DateTime(month.year, month.month + 1, 1);

    final snapshot = await _firestore
        .collection('users')
        .doc(userDocId)
        .collection('Money')
        .where(
          'date&time',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where(
          'date&time',
          isLessThan: Timestamp.fromDate(startOfNextMonth),
        )
        .orderBy('date&time')
        .get();

    final records = snapshot.docs.map(MoneyRecord.fromDoc).toList();

    // Range query already returns ascending order; keep a defensive sort
    // so records without a parseable date stay last instead of crashing.
    records.sort((a, b) {
      final dateA = a.dateTime;
      final dateB = b.dateTime;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateA.compareTo(dateB);
    });

    return records;
  }
}