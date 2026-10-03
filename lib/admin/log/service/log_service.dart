import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/cachehelper/chechehelper.dart';
import '../model/log_model.dart';

/// ONE reusable Admin Audit Log service for every important admin action
/// (user create/update/delete, money add/update/delete, approve, reject,
/// status changes, ...). Screens never write log documents themselves.
///
/// Firestore structure (unchanged):
///
/// ```text
/// users/{adminDocId}/Log/{logId}
/// ```
///
/// IDENTITY — two different ids, never mixed up:
/// * `adminDocId` = WHO performed the action — read dynamically from
///   `CacheHelper().getString('userDocId')` (never hard-coded); the Log
///   folder lives under this admin's document.
/// * `userId` (the [addLog] parameter) = TARGET user affected by the
///   action. It can be a completely different user, or empty when the
///   action had no single target (e.g. a notice-board note).
///
/// Example: admin `users/ADMIN123` edits target `users/USER456`
/// -> document `users/ADMIN123/Log/LOG001` with `user_id: USER456`.
class LogService {
  LogService();

  /// Preferred access: `LogService.instance.addLog(...)`.
  static final LogService instance = LogService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current admin's document id from the cache, or null when the
  /// session cache is missing. Never hard-coded.
  String? get adminDocId => CacheHelper().getString('userDocId');

  String _requireAdminDocId() {
    final String? id = adminDocId;
    if (id == null || id.isEmpty) {
      throw StateError(
        'Cannot access logs: admin session (userDocId) not found in cache.',
      );
    }
    return id;
  }

  CollectionReference<Map<String, dynamic>> _logCollection(String adminDocId) {
    return _firestore
        .collection('users')
        .doc(adminDocId)
        .collection('Log');
  }

  /// Writes one audit entry and returns the created log id.
  ///
  /// * [name], [email] — ADMIN who performed the action.
  /// * [userId] — TARGET user affected by the action.
  /// * [oldData], [newData] — what changed ("" when nothing old exists).
  /// * [note] — short action description ("User updated", "Money added").
  ///
  /// `datetime` uses [FieldValue.serverTimestamp] so a wrong device clock
  /// cannot skew the log. Firebase failures are debug-printed and
  /// re-thrown — never swallowed.
  Future<String> addLog({
    required String name,
    required String email,
    required String userId,
    required String oldData,
    required String newData,
    required String note,
  }) async {
    final String adminDocId = _requireAdminDocId();

    try {
      final docRef = await _logCollection(adminDocId).add({
        'name': name.trim(),
        'email': email.trim(),
        'user_id': userId.trim(),
        'oldData': oldData,
        'newData': newData,
        'notification': note,
        'datetime': FieldValue.serverTimestamp(),
      });

      // Id of the log that was just created (was wrongly cached under
      // the key 'moneyDocRef' before).
      await CacheHelper().setString('logDocRef', docRef.id);
      return docRef.id;
    } on FirebaseException catch (e) {
      debugPrint('addLog failed (${e.code}): ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('addLog failed: $e');
      rethrow;
    }
  }

  /// Real-time stream of the CURRENT admin's logs, newest first.
  ///
  /// The query is exactly `users/{adminDocId}/Log` ordered by `datetime`
  /// descending — a single subcollection stream, so no composite index is
  /// required. Errors flow to the stream listener (the screen shows its
  /// friendly error state); [LogModel] absorbs missing/null fields and
  /// still-pending server timestamps.
  Stream<List<LogModel>> watchLogs() {
    final String adminDocId = _requireAdminDocId();

    return _logCollection(adminDocId)
        .orderBy('datetime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(LogModel.fromFirestore)
              .toList(growable: false),
        );
  }

  /// Log count via the count AGGREGATION — the server counts, the client
  /// downloads no documents (the old `.get()` pulled every log just to
  /// read `docs.length`).
  Future<int> getTotalLogCount() async {
    final String adminDocId = _requireAdminDocId();

    try {
      final aggregate = await _logCollection(adminDocId).count().get();
      return aggregate.count ?? 0;
    } on FirebaseException catch (e) {
      debugPrint('getTotalLogCount failed (${e.code}): ${e.message}');
      rethrow;
    }
  }

  /// Deletes a single log of the current admin.
  Future<void> deleteLog(String logId) async {
    final String adminDocId = _requireAdminDocId();

    try {
      await _logCollection(adminDocId).doc(logId).delete();
    } on FirebaseException catch (e) {
      debugPrint('deleteLog failed (${e.code}): ${e.message}');
      rethrow;
    }
  }

  /// Deletes ALL logs of the current admin, 400 per batch (Firestore
  /// allows max 500 mutations per commit). Returns how many were
  /// deleted. Deleting needs the document references, so those reads are
  /// unavoidable — but only one page of ids is held in memory at a time.
  Future<int> deleteAllLogs() async {
    final String adminDocId = _requireAdminDocId();
    final collection = _logCollection(adminDocId);

    var deleted = 0;

    try {
      while (true) {
        final page = await collection.limit(400).get();
        if (page.docs.isEmpty) break;

        final batch = _firestore.batch();
        for (final doc in page.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        deleted += page.docs.length;
      }
    } on FirebaseException catch (e) {
      debugPrint('deleteAllLogs failed (${e.code}): ${e.message}');
      rethrow;
    }

    return deleted;
  }
}
