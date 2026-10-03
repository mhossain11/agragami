import 'package:cloud_firestore/cloud_firestore.dart';

/// One audit-log entry: `users/{adminDocId}/Log/{logId}`.
///
/// IDENTITY — two different ids, never mixed up:
/// * [adminName] / [adminEmail] = the ADMIN who performed the action
///   (the Log folder lives under that admin's document).
/// * [targetUserId] = the TARGET user affected by the action
///   (empty when the action had no single target, e.g. a notice-board
///   note).
///
/// Every field is parsed defensively — a missing key, a wrong type or a
/// `datetime` that is still `null` while `FieldValue.serverTimestamp()`
/// is being written must never crash the Log screen.
class LogModel {
  const LogModel({
    required this.id,
    required this.adminName,
    required this.adminEmail,
    required this.targetUserId,
    required this.oldData,
    required this.newData,
    required this.action,
    required this.datetime,
  });

  final String id;

  /// Admin who performed the action (Firestore field: `name`).
  final String adminName;

  /// Admin email (Firestore field: `email`).
  final String adminEmail;

  /// Target user affected by the action (Firestore field: `user_id`).
  final String targetUserId;

  final String oldData;
  final String newData;

  /// What happened (Firestore field: `notification`).
  final String action;

  /// `null` while the server timestamp is still pending or if the field
  /// is missing/invalid — the UI shows a placeholder instead of crashing.
  final DateTime? datetime;

  /// The ONLY place a log document is parsed.
  factory LogModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return LogModel.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});
  }

  /// Pure-map core of [fromFirestore] — unit-testable without Firestore.
  factory LogModel.fromMap(String id, Map<String, dynamic> data) {
    final rawDateTime = data['datetime'];

    return LogModel(
      id: id,
      adminName: _text(data['name']),
      adminEmail: _text(data['email']),
      targetUserId: _text(data['user_id']),
      oldData: _text(data['oldData']),
      newData: _text(data['newData']),
      action: _text(data['notification']),
      datetime: rawDateTime is Timestamp ? rawDateTime.toDate() : null,
    );
  }

  /// null / missing / wrong type -> readable String, never throws.
  static String _text(dynamic value) => value?.toString() ?? '';
}
