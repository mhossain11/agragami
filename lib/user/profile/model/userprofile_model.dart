import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String docId;
  final String name;
  final String email;
  final String fatherName;
  final String motherName;
  final String phone;
  final String address;
  final String userId;
  final String nid;
  final String nomineeName;
  final String nomineeRelation;
  final String blood;
  final String birthdate;
  final String profileImage;

  UserProfileModel({
    required this.docId,
    required this.name,
    required this.email,
    required this.fatherName,
    required this.motherName,
    required this.phone,
    required this.address,
    required this.userId,
    required this.nomineeName,
    required this.nomineeRelation,
    required this.nid,
    required this.blood,
    required this.birthdate,
    required this.profileImage,

  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      docId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      fatherName: data['fatherName'] ?? '',
      motherName: data['motherName']?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      userId: data['user_id'] ?? '',
      nomineeName: data['nomineeName'] ?? '',
      nomineeRelation: data['nomineeRelation'] ?? '',
      blood: data['blood'] ?? '',
      nid: data['nid'] ?? '',
      birthdate: data['birthdate'] ?? '',
      profileImage: data['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'fatherName':fatherName,
      'motherName':motherName,
      'phone': phone,
      'address': address,
      'userId': userId,
      'nomineeName': nomineeName,
      'nomineeRelation': nomineeRelation,
      'nid': nid,
      'blood':blood,
      'birthdate': birthdate,
      'profileImage': profileImage,
    };
  }
}