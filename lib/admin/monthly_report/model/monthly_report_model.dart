import 'package:cloud_firestore/cloud_firestore.dart';

/// One row of the monthly report (`users/{userDocId}/Money/{moneyId}`).
class MonthlyMoneyModel {
  const MonthlyMoneyModel({
    required this.userId,
    required this.userName,
    required this.moneyId,
    required this.date,
    required this.amount,
    required this.paymentMethod,
    required this.receivedBy,
    required this.totalAmount,
  });

  final String userId;
  final String userName;
  final String moneyId;
  final DateTime date;
  final double amount;
  final String paymentMethod;
  final String receivedBy;
  final double totalAmount;

  /// The ONLY place a Money document is parsed — every report screen
  /// (monthly report, paid/unpaid report) reuses this factory, so null
  /// handling and type conversion can never drift apart.
  ///
  /// `user_id` / `user_name` come from the denormalized fields stamped by
  /// `SavingMoneyService.addMoney` (legacy docs: `backfillUserFields`).
  factory MonthlyMoneyModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> moneyDoc,
  ) {
    return MonthlyMoneyModel.fromMap(
      moneyDoc.id,
      moneyDoc.data() ?? const <String, dynamic>{},
    );
  }

  /// Pure-map core of [fromFirestore] — same logic, unit-testable
  /// without Firestore.
  factory MonthlyMoneyModel.fromMap(
    String moneyId,
    Map<String, dynamic> data,
  ) {
    final rawDate = data['date&time'];

    return MonthlyMoneyModel(
      userId: data['user_id']?.toString() ?? '',
      userName: data['user_name']?.toString() ?? '',
      moneyId: moneyId,
      // The month query only matches Timestamp values, but the factory is
      // reusable outside of it — stay safe on anything else.
      date: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
      amount: _toDouble(data['amount']),
      paymentMethod: data['payment_method']?.toString() ?? '',
      receivedBy: data['received_by']?.toString() ?? '',
      totalAmount: _toDouble(data['total_amount']),
    );
  }

  /// num / numeric String / anything else -> double, never throws.
  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
