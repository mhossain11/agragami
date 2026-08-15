import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance =
  FirestoreService._();

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
  get users =>
      firestore.collection('users');

  CollectionReference<Map<String, dynamic>>
  get auth =>
      firestore.collection('auth');
}