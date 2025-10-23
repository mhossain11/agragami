
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../cachehelper/chechehelper.dart';

class NoteService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> addNote({
    required String title,
    required String message,
  }) async {
    try {
      final String? userDocId = await CacheHelper().getString('userDocId');

      // Step 2: Money subcollection এ add করা
      final docRef= await _firestore
          .collection('users')
          .doc(userDocId)
          .collection('note')

          .add({
        'title': title,
        'message': message,
        'datetime': Timestamp.now(),
      });
      await CacheHelper().setString('moneyDocRef', docRef.id);
      print('Money added successfully!');
    } catch (e) {
      print('Error adding money: $e');
      rethrow; // চাইলে UI তেও catch করা যায়
    }
  }

}