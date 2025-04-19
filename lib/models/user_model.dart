// lib/models/user_model.dart

class AppUser {
  final String uid;
  final String name;
  final String email;
  final bool isAdmin;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.isAdmin = false,
  });

  factory AppUser.fromJson(Map<String, dynamic> json, String uid) {
    return AppUser(
      uid: uid,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'isAdmin': isAdmin,
    };
  }
}
