import 'package:equatable/equatable.dart';

/// Entidad de dominio: Capítulo de una obra.
class Chapter extends Equatable {
  final String id;
  final String workId;
  final int number;
  final String title;
  final String content;
  final String status;
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
    this.status = 'draft',
    this.wordCount = 0,
    this.readTimeMinutes = 0,
    required this.publishedAt,
    this.isLocked = false,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      workId: json['work_id'] as String? ?? '',
      number: json['order_number'] as int? ?? json['number'] as int? ?? 0,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      wordCount: json['word_count'] as int? ?? 0,
      readTimeMinutes: json['read_time_minutes'] as int? ?? 0,
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? json['created_at'] as String? ?? '') ?? DateTime.now(),
      isLocked: json['is_locked'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id];
}
