class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin' | 'user'
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'created_at': createdAt.toIso8601String(),
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as String,
        email: map['email'] as String,
        name: map['name'] as String? ?? '',
        role: map['role'] as String? ?? 'user',
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}
