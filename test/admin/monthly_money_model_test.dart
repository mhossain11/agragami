import 'package:Agragami/admin/monthly_report/model/monthly_report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Offline checks for the single parsing point of the monthly report
/// (`MonthlyMoneyModel.fromFirestore` delegates to `fromMap`).
void main() {
  test('maps a complete Money document', () {
    final date = DateTime(2026, 3, 15, 10, 30);

    final row = MonthlyMoneyModel.fromMap('money-1', {
      'user_id': 'AG26M001',
      'user_name': 'Rahul Sen',
      'date&time': Timestamp.fromDate(date),
      'amount': 500,
      'payment_method': 'Cash',
      'received_by': 'Admin',
      'total_amount': 1500,
    });

    expect(row.userId, 'AG26M001');
    expect(row.userName, 'Rahul Sen');
    expect(row.moneyId, 'money-1');
    expect(row.date, date);
    expect(row.amount, 500.0);
    expect(row.paymentMethod, 'Cash');
    expect(row.receivedBy, 'Admin');
    expect(row.totalAmount, 1500.0);
  });

  test('survives an empty document without throwing', () {
    final row = MonthlyMoneyModel.fromMap('money-1', const {});

    expect(row.userId, '');
    expect(row.userName, '');
    expect(row.moneyId, 'money-1');
    expect(row.amount, 0);
    expect(row.paymentMethod, '');
    expect(row.receivedBy, '');
    expect(row.totalAmount, 0);
    expect(row.date, isNotNull); // safe fallback, never a crash
  });

  test('converts numeric strings and ignores junk types', () {
    final row = MonthlyMoneyModel.fromMap('money-1', {
      'amount': '250.5',
      'total_amount': '300',
      'payment_method': 12, // wrong type -> stringified, still safe
    });

    expect(row.amount, 250.5);
    expect(row.totalAmount, 300.0);
    expect(row.paymentMethod, '12');
  });

  test('falls back when date&time is not a Timestamp', () {
    final row = MonthlyMoneyModel.fromMap('money-1', {
      'date&time': 'not a timestamp',
    });

    expect(row.date, isNotNull);
  });
}
