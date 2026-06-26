import 'package:equatable/equatable.dart';

/// Entidad de dominio: Capítulo de una obra.
class Chapter extends Equatable {
  final String id;
  final String workId;
  final int number;
  final String title;
  final String content;
  final int wordCount;
  final int readTimeMinutes;
  final DateTime publishedAt;
  final bool isLocked;

  const Chapter({
    required this.id,
    required this.workId,
    required this.number,
    required this.title,
    required this.content,
    this.wordCount = 0,
    this.readTimeMinutes = 0,
    required this.publishedAt,
    this.isLocked = false,
  });

  @override
  List<Object?> get props => [id];
}
