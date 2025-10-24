
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


}