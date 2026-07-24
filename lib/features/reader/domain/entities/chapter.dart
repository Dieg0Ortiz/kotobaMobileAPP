import 'dart:convert';

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

  /// Counts words from chapter content, handling both Quill Delta JSON
  /// and plain text formats.
  static int countWordsFromContent(String raw) {
    if (raw.isEmpty) return 0;

    String plainText;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        // Quill Delta JSON – extract 'insert' strings
        final buffer = StringBuffer();
        for (final op in decoded) {
          if (op is Map && op['insert'] is String) {
            buffer.write(op['insert']);
          }
        }
        plainText = buffer.toString();
      } else {
        plainText = raw;
      }
    } catch (_) {
      plainText = raw;
    }

    plainText = plainText.trim();
    if (plainText.isEmpty) return 0;
    return plainText.split(RegExp(r'\s+')).length;
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'] as String? ?? '';
    final backendWordCount = json['word_count'] as int? ?? 0;
    final computedWordCount = backendWordCount > 0
        ? backendWordCount
        : countWordsFromContent(rawContent);
    final readTime = json['read_time_minutes'] as int? ?? 0;

    return Chapter(
      id: json['id'] as String,
      workId: json['work_id'] as String? ?? '',
      number: json['order_number'] as int? ?? json['number'] as int? ?? 0,
      title: json['title'] as String,
      content: rawContent,
      status: json['status'] as String? ?? 'draft',
      wordCount: computedWordCount,
      readTimeMinutes: readTime > 0 ? readTime : (computedWordCount / 200).ceil(),
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? json['created_at'] as String? ?? '') ?? DateTime.now(),
      isLocked: json['is_locked'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id];

  Map<String, dynamic> toJson() => {
    'id': id,
    'work_id': workId,
    'order_number': number,
    'title': title,
    'content': content,
    'status': status,
    'word_count': wordCount,
    'read_time_minutes': readTimeMinutes,
    'published_at': publishedAt.toIso8601String(),
    'is_locked': isLocked,
  };
}
