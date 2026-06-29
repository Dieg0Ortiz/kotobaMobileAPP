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
  final String genre;
  final List<String> tags;
  final String status; // 'ongoing', 'completed', 'hiatus'
  final int chapterCount;
  final int wordCount;
  final int viewCount;
  final double rating;
  final int ratingCount;
  final String language;
  final String? frequency; // 'weekly', 'biweekly', 'monthly'
  final DateTime publishedAt;
  final DateTime updatedAt;

  const Work({
    required this.id,
    required this.title,
    required this.authorId,
    required this.authorName,
    this.coverUrl,
    required this.synopsis,
    required this.genre,
    this.tags = const [],
    this.status = 'ongoing',
    this.chapterCount = 0,
    this.wordCount = 0,
    this.viewCount = 0,
    this.rating = 0,
    this.ratingCount = 0,
    this.language = 'es',
    this.frequency,
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
      genre: genre,
      tags: tags,
      status: status,
      chapterCount: chapterCount ?? this.chapterCount,
      wordCount: wordCount,
      viewCount: viewCount ?? this.viewCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      language: language,
      frequency: frequency,
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
}
