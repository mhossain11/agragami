import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      // 1️⃣ Check if email exists in your Firestore "users" collection
      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        return "No account found with this email.";
      }

      // 2️⃣ Send reset email if exists
      await _auth.sendPasswordResetEmail(email: email);
      return "Reset link sent! Please check your inbox or spam folder.";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return "Invalid email address.";
      }
      return e.message ?? "Firebase Auth error occurred.";
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }


}