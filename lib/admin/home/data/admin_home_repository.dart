import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/firestore_service.dart';

/// Single source of truth for admin-home data access.
/// UI and controller never touch Firestore/FirebaseAuth directly —
/// everything goes through here.
class AdminHomeRepository {
  AdminHomeRepository({
    required FirestoreService firestoreService,
    required FirebaseAuthService authService,
  })  : _firestoreService = firestoreService,
        _authService = authService;

  final FirestoreService _firestoreService;
  final FirebaseAuthService _authService;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestoreService.users;

  /// Count of users whose `role` field matches [roleName] (case-insensitive).
  Future<int> getTotalUserCount(String roleName) async {
    try {
      final snapshot = await _users.get();
      return snapshot.docs.where((doc) {
        final role = (doc.data()['role'] ?? '').toString().toLowerCase();
        return role == roleName.toLowerCase();
      }).length;
    } catch (e) {
      // Swallow and report 0 — caller decides how to surface errors.
      return 0;
    }
  }

  /// Live sum of every user's `Money/amount` documents.
  /*Stream<int> watchAllUsersTotalAmount() {
    return _users.snapshots().asyncExpand((usersSnapshot) {
      final moneyStreams = usersSnapshot.docs.map((userDoc) {
        return _users
            .doc(userDoc.id)
            .collection('Money')
            .snapshots()
            .map(_sumAmounts);
      }).toList();

      if (moneyStreams.isEmpty) {
        return Stream.value(0);
      }

      return StreamZip<int>(moneyStreams)
          .map((totals) => totals.fold<int>(0, (sum, value) => sum + value));
    });
  }*/
  Stream<int> watchAllUsersTotalAmount() {
    return _firestoreService.firestore
        .collectionGroup('Money')
        .snapshots()
        .map((snapshot) {
      int total = 0;

      for (final doc in snapshot.docs) {
        final amount = doc.data()['amount'];

        if (amount is int) {
          total += amount;
        } else if (amount is double) {
          total += amount.toInt();
        } else if (amount is String) {
          total += int.tryParse(amount) ?? 0;
        }
      }

      return total;
    });
  }

  int _sumAmounts(QuerySnapshot<Map<String, dynamic>> snapshot) {
    var total = 0;

    for (final doc in snapshot.docs) {
      print(doc.data());

      final amount = doc.data()['amount'];

      if (amount is int) {
        total += amount;
      } else if (amount is double) {
        total += amount.toInt();
      } else if (amount is String) {
        total += int.tryParse(amount) ?? 0;
      }
    }

    print('SUB TOTAL = $total');

    return total;
  }

  /// Live profile-image URL for a given user doc id.
  Stream<String> watchProfileImage(String userDocId) {
    return _users.doc(userDocId).snapshots().map((snapshot) {
      final data = snapshot.data();
      return (data?['profileImage'] ?? '').toString();
    });
  }

  Future<void> logout() => _authService.logout();
}
