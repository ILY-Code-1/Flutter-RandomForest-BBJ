// File: user_model.dart
// Model untuk user dengan role (admin dan marketing)

class UserModel {
  final String id;
  final String email;
  final String nama;
  final String role; // 'admin' atau 'marketing'
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.nama,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isMarketing => role == 'marketing';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama': nama,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      nama: json['nama'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? nama,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
