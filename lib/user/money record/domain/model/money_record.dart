import 'package:cloud_firestore/cloud_firestore.dart';

class MoneyRecord {
  final String id;
  final String receivedBy;
  final double amount;
  final String paymentMethod;
  final DateTime? collectionDate;
  final DateTime? dateTime;

  const MoneyRecord({
    required this.id,
    required this.receivedBy,
    required this.amount,
    required this.paymentMethod,
    required this.collectionDate,
    required this.dateTime,
  });

  factory MoneyRecord.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime? dateTime;
    final rawDate = data['date&time'];

    if (rawDate is Timestamp) {
      dateTime = rawDate.toDate();
    } else if (rawDate is String) {
      dateTime = DateTime.tryParse(rawDate);
    }

    DateTime? collectionDate;
    final rawCollectionDate = data['collection_date']; // ⚠️ field নাম কনফার্ম করুন
    if (rawCollectionDate is Timestamp) {
      collectionDate = rawCollectionDate.toDate();
    } else if (rawCollectionDate is String) {
      collectionDate = DateTime.tryParse(rawCollectionDate);
    }

    return  MoneyRecord(
      id: doc.id,
      receivedBy: data['received_by']?.toString() ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      paymentMethod: data['payment_method']?.toString() ?? '',
      collectionDate: collectionDate,
      dateTime: dateTime,
    );
  }
}