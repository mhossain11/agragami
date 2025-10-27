import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String docId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String userId;



  ProfileModel({
    required this.docId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.userId,

  });

  factory ProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfileModel(
      docId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      userId: data['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'userId': userId,
    };
  }
}


