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
}