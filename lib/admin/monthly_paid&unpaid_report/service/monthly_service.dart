import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firestore_service.dart';
import '../model/monthly_report_model.dart';

class MonthlyService {
  MonthlyService();

  static final MonthlyService instance =
  MonthlyService();

  final FirestoreService firestoreService =
      FirestoreService.instance;

  // =====================================================
  // PAID REPORT
  // =====================================================

  Future<List<MonthlyMoneyModel>> getMonthlyReport({
    required int year,
    required int month,
  }) async {
    final List<MonthlyMoneyModel> result = [];

    final startDate = DateTime(year, month, 1);

    final endDate = DateTime(
      year,
      month + 1,
      1,
    );

    final usersSnapshot =
    await firestoreService.users.get();

    for (final userDoc in usersSnapshot.docs) {
      final userData = userDoc.data();

      final userId =
          userData['user_id']?.toString() ??
              userDoc.id;

      final userName =
          userData['name']?.toString() ?? '';

      final moneySnapshot =
      await firestoreService
          .users
          .doc(userDoc.id)
          .collection('Money')
          .get();

      for (final moneyDoc in moneySnapshot.docs) {
        final data = moneyDoc.data();

        // date&time is Timestamp
        final timestamp =
        data['date&time'];

        if (timestamp is! Timestamp) {
          continue;
        }

        final date = timestamp.toDate();

        // Selected month check
        if (date.isBefore(startDate) ||
            !date.isBefore(endDate)) {
          continue;
        }

        result.add(
          MonthlyMoneyModel(
            userId: userId,
            userName: userName,
            moneyId: moneyDoc.id,
            date: date,

            amount: _toDouble(
              data['amount'],
            ),

            paymentMethod:
            data['payment_method']
                ?.toString() ??
                '',

            receivedBy:
            data['received_by']
                ?.toString() ??
                '',

            totalAmount: _toDouble(
              data['total_amount'],
            ),
          ),
        );
      }
    }

    result.sort(
          (a, b) => b.date.compareTo(a.date),
    );

    return result;
  }

  // =====================================================
  // UNPAID MEMBERS
  // =====================================================

  Future<List<Map<String, dynamic>>> getUnpaidMembers({
    required int year,
    required int month,
  }) async {
    final List<Map<String, dynamic>> result = [];

    final paymentMonth =
        '${year}-${month.toString().padLeft(2, '0')}';

    final usersSnapshot =
    await firestoreService.users.get();

    for (final userDoc in usersSnapshot.docs) {
      final userData = userDoc.data();

      final paymentStatus =
      userData['payment_status'];

      bool isPaid = false;

      if (paymentStatus is Map) {
        isPaid =
            paymentStatus[paymentMonth] == true;
      }

      if (!isPaid) {
        result.add({
          'userDocumentId': userDoc.id,

          'userId':
          userData['user_id']?.toString() ??
              userDoc.id,

          'userName':
          userData['name']?.toString() ??
              '',
        });
      }
    }

    return result;
  }

  // =====================================================
  // DOUBLE CONVERTER
  // =====================================================

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }
}