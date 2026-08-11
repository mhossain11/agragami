import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class IdListService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String authId = 'HUbPbYgwEss4dIE4Uiv8';

  // 🔹 Stream all Admin & users (live list)
  Stream<List<Map<String, dynamic>>> getUserList() {
    final adminStream = _firestore
        .collection('auth')
        .doc(authId)
        .collection('admin')
        .snapshots();

    final userStream = _firestore
        .collection('auth')
        .doc(authId)
        .collection('user')
        .snapshots();

    return Rx.combineLatest2(
      adminStream,
      userStream,
          (
          QuerySnapshot adminSnap,
          QuerySnapshot userSnap,
          ) {
        List<Map<String, dynamic>> allUsers = [];

        // Admin list
        for (var doc in adminSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;

          allUsers.add({
            'docId': doc.id,
            'user_id': data.containsKey('user_id') ? data['user_id'] : 'N/A',
            'user': data.containsKey('user') ? data['user'] : 'N/A', // safer
          });
        }


        // User list
        for (var doc in userSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;

          allUsers.add({
            'docId': doc.id,
            'user_id': data.containsKey('user_id') ? data['user_id'] : 'N/A',
            'user': data.containsKey('user') ? data['user'] : 'N/A', // safer
          });
        }

        return allUsers;
      },
    );
  }
}