class User {
  final int? id;
  final String username;
  final String password;
  final String role;
  final String fullName;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.fullName,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'role': role,
    'full_name': fullName,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int?,
    username: json['username'] as String,
    password: json['password'] as String,
    role: json['role'] as String,
    fullName: json['full_name'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? role,
    String? fullName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    username: username ?? this.username,
    password: password ?? this.password,
    role: role ?? this.role,
    fullName: fullName ?? this.fullName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
