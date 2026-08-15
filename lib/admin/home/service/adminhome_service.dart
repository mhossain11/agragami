import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AdminHomeService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Get total number of users where role is 'user' (case-insensitive)
  Future<int> getTotalUserCount(String roleName) async {
    try {
      // Step 1: Get all documents from 'users'
      QuerySnapshot snapshot = await _firestore.collection('users').get();

      // Step 2: Filter manually (case-insensitive check)
      final filtered = snapshot.docs.where((doc) {
        final role = (doc['role'] ?? '').toString().toLowerCase();
        return role == roleName;
      }).toList();

      // Step 3: Return total count
      return filtered.length;
    } catch (e) {
      print('❌ Error fetching user count: $e');
      return 0;
    }
  }

  Stream<int> getAllUsersTotalAmountStream() {
    final usersCollection = FirebaseFirestore.instance.collection('users');

    // Listen to users collection
    return usersCollection.snapshots().asyncExpand((usersSnapshot) {
      // For each user, create a stream of their Money subcollection
      final moneyStreams = usersSnapshot.docs.map((userDoc) {
        final moneyCollection = usersCollection.doc(userDoc.id).collection('Money');

        // Listen to Money collection live
        return moneyCollection.snapshots().map((QuerySnapshot moneySnapshot) {
          int userTotal = 0;

          for (var moneyDoc in moneySnapshot.docs) {
            final amount = moneyDoc['amount'];
            if (amount is int) userTotal += amount;
            else if (amount is double) userTotal += amount.toInt();
            else if (amount is String) userTotal += int.tryParse(amount) ?? 0;
          }

          return userTotal; // total for this user
        });
      }).toList();

      // Combine all users' totals into one stream
      return StreamZip<int>(moneyStreams).map((totals) {
        return totals.fold(0, (sum, value) => sum + value);
      });
    });
  }












}