class User {
  final int? id;
  final String username;
  final String? email;
  final String role;
  final int? barberId;

  User({
    this.id,
    required this.username,
    this.email,
    required this.role,
    this.barberId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'CLIENT',
      barberId: json['barberId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'barberId': barberId,
    };
  }

  bool get isAdmin => role == 'ADMIN';
  bool get isBarber => role == 'BARBER';
  bool get isClient => role == 'CLIENT';

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? role,
    int? barberId,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      barberId: barberId ?? this.barberId,
    );
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}
