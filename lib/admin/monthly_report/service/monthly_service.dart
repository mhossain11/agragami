import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firestore_service.dart';
import '../model/monthly_report_model.dart';

class MonthlyService {
  MonthlyService();

  static final MonthlyService instance =
  MonthlyService();

  final FirestoreService firestoreService =
      FirestoreService.instance;

  Future<List<MonthlyMoneyModel>> getMonthlyReport({
    required int year,
    required int month,
  }) async {
    final List<MonthlyMoneyModel> result = [];

    final startDate = DateTime(
      year,
      month,
      1,
    );

    final endDate = DateTime(
      year,
      month + 1,
      1,
    );

    print('==============================');
    print('Monthly Report');
    print('Start: $startDate');
    print('End: $endDate');
    print('==============================');

    // সব users
    final usersSnapshot =
    await firestoreService.users.get();

    print(
      'Total Users: ${usersSnapshot.docs.length}',
    );

    for (final userDoc
    in usersSnapshot.docs) {
      final userData = userDoc.data();

      final userId =
          userData['user_id'] ??
              userDoc.id;

      final userName =
          userData['name'] ??
              '';

      print(
        'User: $userId | $userName',
      );

      // User এর Money collection
      final moneySnapshot =
      await firestoreService
          .users
          .doc(userDoc.id)
          .collection('Money')
          .get();

      print(
        'Money count: '
            '${moneySnapshot.docs.length}',
      );

      for (final moneyDoc
      in moneySnapshot.docs) {
        final data = moneyDoc.data();

        print(
          'Money ID: ${moneyDoc.id}',
        );

        print(
          'Money Data: $data',
        );

        // -------------------------
        // CREATE TIME
        // -------------------------

        final timestamp =
        data['create_time'];

        if (timestamp is! Timestamp) {
          print(
            'SKIP: create_time is not Timestamp',
          );
          continue;
        }

        final date =
        timestamp.toDate();

        print(
          'Payment date: $date',
        );

        // -------------------------
        // MONTH FILTER
        // -------------------------

        if (date.isBefore(startDate)) {
          print(
            'SKIP: before start date',
          );
          continue;
        }

        if (!date.isBefore(endDate)) {
          print(
            'SKIP: after end date',
          );
          continue;
        }

        // -------------------------
        // ADD REPORT
        // -------------------------

        result.add(
          MonthlyMoneyModel(
            userId:
            userId.toString(),

            userName:
            userName.toString(),

            moneyId:
            moneyDoc.id,

            date:
            date,

            amount:
            _toDouble(
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

            totalAmount:
            _toDouble(
              data['total_amount'],
            ),
          ),
        );

        print(
          'ADDED TO REPORT: '
              '${moneyDoc.id}',
        );
      }
    }

    result.sort(
          (a, b) =>
          b.date.compareTo(a.date),
    );

    print(
      'FINAL REPORT COUNT: '
          '${result.length}',
    );

    return result;
  }

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    ) ??
        0;
  }
}