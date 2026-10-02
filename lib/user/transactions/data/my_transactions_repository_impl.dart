import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/cachehelper/chechehelper.dart';
import '../../money record/domain/model/money_record.dart';
import '../domain/model/my_transactions_data.dart';
import '../domain/repository/my_transactions_repository.dart';

/// Loads the signed-in member's profile and `Money` records straight
/// from Firebase Auth + Firestore.
///
/// Security: no id is ever taken from the UI. The primary source is
/// `FirebaseAuth.currentUser.uid`; when the app's own cached session is
/// the only thing left (kill app -> reopen still logged in), the cached
/// member doc id is used as a fallback - and Firestore Security Rules
/// (see `firestore.rules`) still decide whether that data may actually
/// be read, so a tampered client gains nothing once the rules are
/// deployed.
class MyTransactionsRepositoryImpl implements MyTransactionsRepository {
  MyTransactionsRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Exception _sessionExpired() => Exception(
        'Your login session is no longer valid. '
        'Please log out and log in again.',
      );

  @override
  Future<MyTransactionsData> loadMyTransactions() async {
    // --- Primary: the live Firebase Auth session ------------------------
    // A freshly launched app may still be restoring its persisted auth
    // session - give it a moment before concluding there is none.
    var firebaseUser = _auth.currentUser ??
        await _auth
            .authStateChanges()
            .first
            .timeout(const Duration(seconds: 2), onTimeout: () => null);

    final uid = firebaseUser?.uid;
    final userSnapshot = await _resolveUserSnapshot(uid);

    final userData = userSnapshot.data() ?? <String, dynamic>{};

    // --- ONLY this member's own Money subcollection ---------------------
    List<QueryDocumentSnapshot<Map<String, dynamic>>> moneyDocs;
    try {
      moneyDocs =
          (await userSnapshot.reference.collection('Money').get()).docs;
    } on FirebaseException catch (e) {
      // Rules denied the read: there is no valid Auth session for this
      // data (e.g. the cached session outlived the Firebase user).
      if (e.code == 'permission-denied') {
        throw _sessionExpired();
      }
      rethrow;
    }

    final transactions = moneyDocs.map(MoneyRecord.fromDoc).toList();
    sortTransactionsNewestFirst(transactions);

    return MyTransactionsData(
      name: userData['name']?.toString() ?? '',
      userId: userData['user_id']?.toString() ?? uid ?? '',
      email: userData['email']?.toString() ?? firebaseUser?.email ?? '',
      phone: userData['phone']?.toString() ?? '',
      transactions: transactions,
    );
  }

  /// Finds `users/{docId}` for the current session.
  Future<DocumentSnapshot<Map<String, dynamic>>> _resolveUserSnapshot(
    String? uid,
  ) async {
    // users/{uid} - the document id is the Firebase Auth uid (see
    // AuthRemoteDataSource.createUser).
    if (uid != null && uid.isNotEmpty) {
      final direct = await _firestore.collection('users').doc(uid).get();
      if (direct.exists) return direct;

      // Legacy accounts keep the uid only inside the `uid` field.
      final byUidField = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
      if (byUidField.docs.isNotEmpty) return byUidField.docs.first;

      throw _sessionExpired();
    }

    // Fallback: no Firebase Auth user (expired/revoked session, recreated
    // account) but the app still holds its cached member session.
    final cachedDocId = CacheHelper().getString('userDocId') ?? '';
    if (cachedDocId.isEmpty) throw _sessionExpired();

    final cached = await _firestore.collection('users').doc(cachedDocId).get();
    if (!cached.exists) throw _sessionExpired();

    return cached;
  }
}
