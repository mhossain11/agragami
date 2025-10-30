import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../cachehelper/chechehelper.dart';


class AuthService {
  //Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // FireStore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Register
  Future<String?> signup({
    required String email,
    required String password,
    required String name,
    required String role,
    required String user_id,
    required String phone,
    required String address,
    required String birthdate,
    required String nid,
    required String nomineeName,
    required String nomineeRelation,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await _firestore.collection('users').
      doc(userCredential.user!.uid).
      set({
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
        'user_id': user_id.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
        'birthdate': birthdate.trim(),
        'nid': nid.trim(),
        'nomineeName': nomineeName.trim(),
        'nomineeRelation': nomineeRelation.trim(),
        'uid': userCredential.user!.uid,
        'created_at': Timestamp.now(),
      });
      // userCredential.user!.uid
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'This email is used.';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }


  //Sing up
  Future<String?> Login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth
          .signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // ✅ Save user info locally using SharedPreferences
      await CacheHelper().setLoggedIn(userDoc.exists);
      await CacheHelper().setString('isRole', userDoc['role'].toString());
      await CacheHelper().setString('names', userDoc['name'].toString());
      await CacheHelper().setString('adminId', userDoc['user_id'].toString());
      await CacheHelper().setString('email', userDoc['email'].toString());
      await CacheHelper().setString('userDocId', userDoc.id.toString());

      if (userDoc.exists) {
        return userDoc['role'] as String;
      } else {
        return 'User data not found in Firestore.';
      }
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Auth Error: ${e.code} - ${e.message}");
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

//check  user_id by auth collection list
  Future<Map<String, dynamic>?> checkUserAdminRole(String inputUserId) async {
    try {
      // 🔹 প্রথমে auth collection থেকে সব doc নিয়ে loop করব
      final authSnapshot = await _firestore.collection('auth').get();

      for (var authDoc in authSnapshot.docs) {
        final docId = authDoc.id;

        // 🔸 1. Check in admin subcollection
        final adminSnapshot = await _firestore
            .collection('auth')
            .doc(docId)
            .collection('admin')
            .where('user_id', isEqualTo: inputUserId)
            .limit(1)
            .get();

        if (adminSnapshot.docs.isNotEmpty) {
          return {
            'role': 'admin',
            'authDocId': docId,
            'userDocId': adminSnapshot.docs.first.id,
          };
        }

        // 🔸 2. Check in user subcollection
        final userSnapshot = await _firestore
            .collection('auth')
            .doc(docId)
            .collection('user')
            .where('user_id', isEqualTo: inputUserId)
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          return {
            'role': 'user',
            'authDocId': docId,
            'userDocId': userSnapshot.docs.first.id,
          };
        }
      }

      // 🔻 কিছু না পেলে null রিটার্ন
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  //check  user_id by users collection list
  Future<Map<String, dynamic>?> checkUserRole(String inputUserId) async {
    try {
      // 🔹 user_id মিলে এমন ডকুমেন্ট খুঁজো
      final userSnapshot = await _firestore
          .collection('users')
          .where('user_id', isEqualTo: inputUserId)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final doc = userSnapshot.docs.first.data();

        return {
          'user_id': inputUserId,
          'exists': true,
          'role': doc['role'], // Firestore থেকে আসা role
          'userDocId': userSnapshot.docs.first.id,
        };
      }

      // 🔻 কিছু না পাওয়া গেলে
      return {
        'exists': false,
        'role': null,
      };
    } catch (e) {
      print('Error checking role: $e');
      return null;
    }
  }

  //auth collection user Added 'user: done'
  Future<void> addUserDoneFieldById(String userId) async {
    try {
      // 🔹 Step 0: Get all auth document IDs
      final authSnapshot = await FirebaseFirestore.instance
          .collection('auth')
          .get();
      final authDocIds = authSnapshot.docs.map((doc) => doc.id).toList();

      bool updated = false;

      // 🔹 Step 1: Loop through each auth doc
      for (String authDocId in authDocIds) {
        final adminRef = FirebaseFirestore.instance
            .collection('auth')
            .doc(authDocId)
            .collection('admin');

        final userRef = FirebaseFirestore.instance
            .collection('auth')
            .doc(authDocId)
            .collection('user');

        // 🔹 Step 2: Check in admin
        final adminSnapshot =
        await adminRef.where('user_id', isEqualTo: userId).limit(1).get();
        if (adminSnapshot.docs.isNotEmpty) {
          await adminSnapshot.docs.first.reference.update({'user': 'done'});
          print("✅ Added 'user: done' in admin of auth/$authDocId for $userId");
          updated = true;
          break; // match হলে loop বন্ধ
        }

        // 🔹 Step 3: Check in user
        final userSnapshot =
        await userRef.where('user_id', isEqualTo: userId).limit(1).get();
        if (userSnapshot.docs.isNotEmpty) {
          await userSnapshot.docs.first.reference.update({'user': 'done'});
          print("✅ Added 'user: done' in user of auth/$authDocId for $userId");
          updated = true;
          break; // match হলে loop বন্ধ
        }
      }

      if (!updated) {
        print("⚠️ No user found with user_id: $userId in any auth doc.");
      }
    } catch (e) {
      print("❌ Error in addUserDoneFieldById: $e");
    }
  }
}
