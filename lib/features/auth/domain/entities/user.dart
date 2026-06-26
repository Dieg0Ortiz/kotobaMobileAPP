import 'package:equatable/equatable.dart';

/// Entidad de dominio: Usuario.
///
/// Pura Dart, sin dependencias de Flutter ni librerías externas.
/// Usada tanto para el usuario logueado como para perfiles de autor.
class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? bio;
  final String? avatarUrl;
  final String? bannerUrl;
  final String role; // 'reader', 'author', 'admin'
  final int followers;
  final int following;
  final int worksCount;
  final int totalReads;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.username,
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

  @override
  List<Object?> get props => [id, email, username, role];
}
