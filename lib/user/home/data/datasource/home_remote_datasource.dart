/*
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firestore_service.dart';

class HomeRemoteDataSource {
  final FirestoreService firestoreService;

  HomeRemoteDataSource( this.firestoreService,);

  Future<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return firestoreService.usersCollection.get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserMoney(
      String userId) {
    return firestoreService
        .usersCollection
        .doc(userId)
        .collection('Money')
        .get();
  }
}*/
