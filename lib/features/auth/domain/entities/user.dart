import 'package:equatable/equatable.dart';

/// Entidad de dominio: Usuario.
class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final int? age;
  final String? country;
  final String? bio;
  final String? avatarUrl;
  final String? bannerUrl;
  final String role;
  final int followers;
  final int following;
  final int worksCount;
  final int totalReads;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.age,
    this.country,
    this.bio,
    this.avatarUrl,
    this.bannerUrl,
    this.role = 'reader',
    this.followers = 0,
    this.following = 0,
    this.worksCount = 0,
    this.totalReads = 0,
    required this.createdAt,
  });

  bool get isAuthor => role == 'author' || role == 'admin';

  /// Crea un User desde los datos del formulario de registro (útil para UI optimista).
  factory User.fromRegistration({
    required String email,
    required String username,
    int? age,
    String? country,
  }) {
    return User(
      id: '',
      email: email,
      username: username,
      age: age,
      country: country,
      createdAt: DateTime.now(),
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      age: json['age'] as int?,
      country: json['country'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      role: json['role'] as String? ?? 'reader',
      followers: (json['followers'] ?? json['followers_count'] ?? 0) as int,
      following: (json['following'] ?? json['following_count'] ?? 0) as int,
      worksCount: (json['works_count'] ?? json['published_works'] ?? 0) as int,
      totalReads: (json['total_reads'] ?? 0) as int,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, email, username, role];
}
