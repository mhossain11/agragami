import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firestore_service.dart';
import '../model/monthly_report_model.dart';

/// User-facing report error: a Firebase failure mapped to a readable
/// message ([cause] keeps the original exception for debugging).
class MonthlyReportException implements Exception {
  MonthlyReportException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

/// Monthly report data access.
///
/// ONE `collectionGroup('Money')` query with the month range applied
/// SERVER-side:
///
/// * reads = only the selected month's transactions (never all money
///   docs, never the `users` collection);
/// * network = 1 round trip no matter how many members exist;
/// * sorting = `orderBy('date&time', descending: true)` done by
///   Firestore — the client never sorts;
/// * parsing = only [MonthlyMoneyModel.fromFirestore].
///
/// Needs `user` / `user_id` / `user_name` on every Money doc (written by
/// `SavingMoneyService.addMoney`; legacy docs once via
/// [backfillUserFields]). Requires the collection-group index on
/// `date&time` — see `firestore.indexes.json`.
class MonthlyService {
  MonthlyService();

  static final MonthlyService instance = MonthlyService();

  final FirebaseFirestore _firestore = FirestoreService.instance.firestore;

  /// Transactions of exactly [month] in [year], newest first.
  ///
  /// The end bound is EXCLUSIVE and `DateTime` normalises `month + 1`
  /// automatically (December -> 1 January of the next year), so the range
  /// is always exactly one calendar month.
  Future<List<MonthlyMoneyModel>> getMonthlyReport({
    required int year,
    required int month,
  }) async {
    final DateTime start = DateTime(year, month, 1);
    final DateTime end = DateTime(year, month + 1, 1);

    try {
      final snapshot = await _firestore
          .collectionGroup('Money')
          .where(
            'date&time',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .where(
            'date&time',
            isLessThan: Timestamp.fromDate(end),
          )
          .orderBy('date&time', descending: true)
          .get();

      // Firestore already filtered and sorted — only map the documents.
      return snapshot.docs
          .map(MonthlyMoneyModel.fromFirestore)
          .toList(growable: false);
    } on FirebaseException catch (e) {
      throw MonthlyReportException(_friendlyMessage(e.code), e);
    }
  }

  /// One-time maintenance for Money docs created before the denormalized
  /// owner fields existed. Run once from an admin-only action, then remove
  /// the call — new documents are stamped by `SavingMoneyService.addMoney`.
  ///
  /// Returns how many documents were updated.
  Future<int> backfillUserFields() async {
    final usersSnapshot = await _firestore.collection('users').get();
    final profileByDocId = <String, ({String userId, String userName})>{
      for (final user in usersSnapshot.docs)
        user.id: (
          userId: user.data()['user_id']?.toString() ?? user.id,
          userName: user.data()['name']?.toString() ?? '',
        ),
    };

    final moneySnapshot = await _firestore.collectionGroup('Money').get();

    var updated = 0;
    var batch = _firestore.batch();
    var pending = 0;

    for (final doc in moneySnapshot.docs) {
      final data = doc.data();
      if (data.containsKey('user') &&
          data.containsKey('user_id') &&
          data.containsKey('user_name')) {
        continue;
      }

      // Path is users/{userDocId}/Money/{moneyId} -> parent id = [1].
      final segments = doc.reference.path.split('/');
      final profile =
          segments.length >= 4 ? profileByDocId[segments[1]] : null;
      if (profile == null) continue;

      batch.set(
        doc.reference,
        {
          // Dynamic: the ACTUAL parent user document of this Money doc.
          'user': doc.reference.parent.parent,
          'user_id': profile.userId,
          'user_name': profile.userName,
        },
        SetOptions(merge: true),
      );
      updated++;
      pending++;

      // Firestore allows max 500 mutations per commit.
      if (pending == 400) {
        await batch.commit();
        batch = _firestore.batch();
        pending = 0;
      }
    }

    if (pending > 0) await batch.commit();

    return updated;
  }

  String _friendlyMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to view this report.';
      case 'unavailable':
        return 'No internet connection. Please try again.';
      case 'failed-precondition':
        return 'Firestore still needs its index for this report. '
            'Check the Firebase console (see firestore.indexes.json).';
      default:
        return 'Could not load the monthly report. Please try again.';
    }
  }
}
