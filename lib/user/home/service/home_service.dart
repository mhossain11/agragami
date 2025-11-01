import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getUserTotalMoney(String userDocId) async {
    double total = 0;

    final snapshot = await FirebaseFirestore.instance
        .collection('users') // plural
        .doc(userDocId)
        .collection('Money')
        .get();


    for (var doc in snapshot.docs) {
      final data = doc.data();
      final amount = data['amount'];
      double value = 0;
      if (amount is int) {
        value = amount.toDouble();
      } else if (amount is double) value = amount;
      else if (amount is String) value = double.tryParse(amount) ?? 0;

      total += value;
    }
    return total.toInt();
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