import 'package:Agragami/admin/log/model/log_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Offline checks for the single parsing point of the admin audit log
/// (`LogModel.fromFirestore` delegates to `fromMap`).
void main() {
  test('maps a complete log document', () {
    final datetime = DateTime(2026, 10, 2, 23, 30);

    final row = LogModel.fromMap('LOG001', {
      'name': 'John Admin',
      'email': 'admin@gmail.com',
      'user_id': 'USER456',
      'oldData': 'Name: Rahim',
      'newData': 'Name: Karim',
      'notification': 'User name updated',
      'datetime': Timestamp.fromDate(datetime),
    });

    expect(row.id, 'LOG001');
    expect(row.adminName, 'John Admin');
    expect(row.adminEmail, 'admin@gmail.com');
    expect(row.targetUserId, 'USER456');
    expect(row.oldData, 'Name: Rahim');
    expect(row.newData, 'Name: Karim');
    expect(row.action, 'User name updated');
    expect(row.datetime, datetime);
  });

  test('survives an empty document without throwing', () {
    final row = LogModel.fromMap('LOG002', const {});

    expect(row.adminName, '');
    expect(row.adminEmail, '');
    expect(row.targetUserId, '');
    expect(row.action, '');
    expect(row.datetime, null); // missing field -> null, never a crash
  });

  test('pending serverTimestamp (null datetime) is handled', () {
    final row = LogModel.fromMap('LOG003', {
      'datetime': null, // FieldValue.serverTimestamp() still writing
      'user_id': 'USER456',
    });

    expect(row.datetime, null);
    expect(row.targetUserId, 'USER456');
  });

  test('junk types are stringified safely, never crash', () {
    final row = LogModel.fromMap('LOG004', {
      'name': 123,
      'user_id': true,
      'datetime': 'not a timestamp',
    });

    expect(row.adminName, '123');
    expect(row.targetUserId, 'true');
    expect(row.datetime, null);
  });
}
