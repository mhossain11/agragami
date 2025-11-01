import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String docId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String userId;
  final String nid;
  final String nomineeName;
  final String nomineeRelation;
  final String birthdate;
  final String profileImage;

  UserProfileModel({
    required this.docId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.userId,
    required this.nomineeName,
    required this.nomineeRelation,
    required this.nid,
    required this.birthdate,
    required this.profileImage,

  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      docId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      userId: data['user_id'] ?? '',
      nomineeName: data['nomineeName'] ?? '',
      nomineeRelation: data['nomineeRelation'] ?? '',
      nid: data['nid'] ?? '',
      birthdate: data['birthdate'] ?? '',
      profileImage: data['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'userId': address,
      'nomineeName': nomineeName,
      'nomineeRelation': nomineeRelation,
      'nid': nid,
      'birthdate': birthdate,
      'profileImage': profileImage,
    };
  }
}