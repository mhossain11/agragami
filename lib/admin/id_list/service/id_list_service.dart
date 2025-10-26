import 'package:cloud_firestore/cloud_firestore.dart';

class IdListService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String authId = 'HUbPbYgwEss4dIE4Uiv8';

  // 🔹 Stream all users (live list)
  Stream<List<Map<String, dynamic>>> getUserList() {
    return _firestore
        .collection('auth')
        .doc(authId)
        .collection('user')
        .snapshots()
        .map((snapshot) {
      print("Docs found: ${snapshot.docs.length}");
      for (var doc in snapshot.docs) {
        print(doc.data());
      }
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'docId': doc.id,
          'user_id': data.containsKey('user_id') ? data['user_id'] : 'N/A',
          'user': data.containsKey('user') ? data['user'] : 'N/A', // safer
        };
      }).toList();
    });
  }
}