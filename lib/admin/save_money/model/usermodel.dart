
class UserModel {
  final String name;
  final String email;
  final String role;
  final String userid;
  final String? profileImage;
  final String? phone;

  UserModel({
    required this.name,
    required this.email,
    required this.role,
    required this.userid,
    this.profileImage =" ",
    this.phone,
  });

  // 🔹 Convert Firestore/Map to Model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      userid: json['user_id'] ?? '', // Firestore এ যদি key 'user_id' হয়
      profileImage: json['profileImage'] ?? '',
      phone: json['phone']?.toString(),
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
      if (phone != null) 'phone': phone,
    };
  }
}
