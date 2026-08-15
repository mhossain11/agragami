import 'dart:io';

class RegisterRequest {
  final String userId;
  final String name;
  final String email;
  final String password;
  final String role;
  final String phone;
  final String address;
  final String birthdate;
  final String nid;
  final String nomineeName;
  final String nomineeRelation;
  final File profileImage;

  RegisterRequest({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.phone,
    required this.address,
    required this.birthdate,
    required this.nid,
    required this.nomineeName,
    required this.nomineeRelation,
    required this.profileImage,
  });
}