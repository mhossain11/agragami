
class UserModel {
  final String name;
  final String email;
  final String role;
  final String userid;
  final String? profileImage;

  UserModel({
    required this.name,
    required this.email,
    required this.role,
    required this.userid,
    this.profileImage =" "
  });

  // 🔹 Convert Firestore/Map to Model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      userid: json['user_id'] ?? '', // Firestore এ যদি key 'user_id' হয়
      profileImage: json['profileImage'] ?? '',
    );
  }

  // 🔹 Convert Model to Map (for Firestore upload)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'user_id': userid,
      'profileImage': profileImage,
    };
  }
}
