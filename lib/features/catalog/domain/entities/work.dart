import 'package:equatable/equatable.dart';

/// Entidad de dominio: Obra literaria.
///
/// Representa una novela, fanfiction o serie de capítulos en el catálogo.
class Work extends Equatable {
  final String id;
  final String title;
  final String authorId;
  final String authorName;
  final String? coverUrl;
  final String synopsis;
  final List<String> genres;
  final List<String> tags;
  final String status; // 'ongoing', 'completed', 'hiatus'
  final int chapterCount;
  final int wordCount;
  final int viewCount;
  final double rating;
  final int ratingCount;
  final String language;
  final String? frequency; // 'weekly', 'biweekly', 'monthly'
  final bool isMature;
  final DateTime publishedAt;
  final DateTime updatedAt;

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      id: json['id'] as String,
      title: json['title'] as String,
      authorId: json['author_id'] as String,
      authorName: (json['author_name'] as String?) ?? (json['users'] is Map ? (json['users'] as Map)['username'] as String? ?? '' : ''),
      coverUrl: json['cover_url'] as String?,
      synopsis: json['synopsis'] as String? ?? json['description'] as String? ?? '',
      genres: (json['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      status: json['status'] as String? ?? 'ongoing',
      chapterCount: json['chapters'] is Map ? (json['chapters'] as Map)['count'] as int? ?? 0 : (json['chapter_count'] as int? ?? 0),
      wordCount: json['word_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: json['rating_count'] as int? ?? 0,
      language: json['language'] as String? ?? 'es',
      frequency: json['frequency'] as String?,
      isMature: json['is_mature'] as bool? ?? false,
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  const Work({
    required this.id,
    required this.title,
    required this.authorId,
    required this.authorName,
    this.coverUrl,
    required this.synopsis,
    this.genres = const [],
    this.tags = const [],
    this.status = 'ongoing',
    this.chapterCount = 0,
    this.wordCount = 0,
    this.viewCount = 0,
    this.rating = 0,
    this.ratingCount = 0,
    this.language = 'es',
    this.frequency,
    this.isMature = false,
    required this.publishedAt,
    required this.updatedAt,
  });

  Work copyWith({
    double? rating,
    int? ratingCount,
    int? viewCount,
    int? chapterCount,
  }) {
    return Work(
      id: id,
      title: title,
      authorId: authorId,
      authorName: authorName,
      coverUrl: coverUrl,
      synopsis: synopsis,
      genres: genres,
      tags: tags,
      status: status,
      chapterCount: chapterCount ?? this.chapterCount,
      wordCount: wordCount,
      viewCount: viewCount ?? this.viewCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      language: language,
      frequency: frequency,
      isMature: isMature,
      publishedAt: publishedAt,
      updatedAt: updatedAt,
    );
  }

  String get formattedWordCount {
    if (wordCount >= 1000) {
      return '${(wordCount / 1000).toStringAsFixed(1)}k';
    }
    return wordCount.toString();
  }

  String get formattedViewCount {
    if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}k';
    }
    return viewCount.toString();
  }

  @override
  List<Object?> get props => [id];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author_id': authorId,
    'author_name': authorName,
    'cover_url': coverUrl,
    'synopsis': synopsis,
    'genres': genres,
    'tags': tags,
    'status': status,
    'chapter_count': chapterCount,
    'word_count': wordCount,
    'view_count': viewCount,
    'rating': rating,
    'rating_count': ratingCount,
    'language': language,
    'frequency': frequency,
    'is_mature': isMature,
    'published_at': publishedAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
