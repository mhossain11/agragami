import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyMoneyModel {
  final String userId;
  final String userName;
  final String moneyId;
  final DateTime date;
  final double amount;
  final String paymentMethod;
  final String receivedBy;
  final double totalAmount;

  MonthlyMoneyModel({
    required this.userId,
    required this.userName,
    required this.moneyId,
    required this.date,
    required this.amount,
    required this.paymentMethod,
    required this.receivedBy,
    required this.totalAmount,
  });

  factory MonthlyMoneyModel.fromFirestore({
    required DocumentSnapshot<Map<String, dynamic>> moneyDoc,
    required String userId,
    required String userName,
  }) {
    final data = moneyDoc.data() ?? {};

    final createTime = data['date&time'];

    return MonthlyMoneyModel(
      userId: userId,
      userName: userName,
      moneyId: moneyDoc.id,
      date: createTime is Timestamp
          ? createTime.toDate()
          : DateTime.now(),
      amount: (data['amount'] ?? 0).toDouble(),
      paymentMethod: data['payment_method'] ?? '',
      receivedBy: data['received_by'] ?? '',
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
    );
  }
}