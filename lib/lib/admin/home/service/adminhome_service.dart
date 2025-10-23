import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../cachehelper/chechehelper.dart';

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


// Sum TotalAmount
  Stream<int> getAllUsersTotalAmountStream() {
    final usersCollection = _firestore.collection('users');

    // 1️⃣ প্রথমে users এর লাইভ snapshots
    return usersCollection.snapshots().asyncMap((usersSnapshot) async {
      int grandTotal = 0;

      // 2️⃣ প্রতিটি user এর Money subcollection এর snapshots নিয়ে আসে
      for (var userDoc in usersSnapshot.docs) {
        final moneyCollection = usersCollection.doc(userDoc.id).collection('Money');

        // Money collection এর সব doc এর লাইভ data
        final moneySnapshot = await moneyCollection.get();
        for (var moneyDoc in moneySnapshot.docs) {
          final data = moneyDoc.data();
          final amount = data['amount'];

          if (amount is int) {
            grandTotal += amount;
          } else if (amount is double) {
            grandTotal += amount.toInt();
          } else if (amount is String) {
            grandTotal += int.tryParse(amount) ?? 0;
          }
        }
      }

      return grandTotal;
    });
  }





}