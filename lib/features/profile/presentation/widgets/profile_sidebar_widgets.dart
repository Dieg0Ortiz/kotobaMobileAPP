import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_avatar.dart';
import '../providers/profile_providers.dart';

class AchievementsCard extends StatelessWidget {
  const AchievementsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      title: 'LOGROS Y RECONOCIMIENTOS',
      child: Wrap(
        spacing: 12,
        children: MockData.achievements.map((a) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(a['icon'] as String),
              color: _getColor(a['color'] as String),
              size: 24,
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'verified': return Icons.verified;
      case 'local_fire_department': return Icons.local_fire_department;
      case 'menu_book': return Icons.menu_book;
      default: return Icons.star;
    }
  }

  Color _getColor(String name) {
    switch (name) {
      case 'gold': return Colors.amber;
      case 'action': return AppColors.action;
      case 'primary': return AppColors.primary;
      default: return AppColors.onSurface;
    }
  }
}

class GenresCard extends StatelessWidget {
  const GenresCard({super.key});

  @override
  Widget build(BuildContext context) {
    final genres = ['Ciencia Ficción', 'Ciberpunk', 'Fantasía Oscura', 'Thriller'];
    return _buildCard(
      title: 'GÉNEROS QUE ESCRIBE',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: genres.map((g) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(g, style: KotobaTypography.labelXs),
          );
        }).toList(),
      ),
    );
  }
}

class ActivityTimeline extends StatelessWidget {
  const ActivityTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      title: 'ACTIVIDAD RECIENTE',
      child: Column(
        children: MockData.recentActivity.map((activity) {
          final isHighlight = activity['isHighlight'] as bool;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4, right: 12),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isHighlight ? AppColors.action : AppColors.onSurfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: KotobaTypography.bodyMd.copyWith(color: AppColors.onSurface),
                          children: [
                            TextSpan(
                              text: '${activity['action']} ',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: activity['target'] as String,
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity['time'] as String,
                        style: KotobaTypography.labelXs.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SimilarAuthorsCard extends ConsumerWidget {
  const SimilarAuthorsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(followingAuthorsProvider);

    return followingAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (authors) {
        if (authors.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'SIGUIENDO',
                    style: KotobaTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 125,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: authors.length,
                itemBuilder: (context, index) {
                  final userJson = (authors[index]['user'] as Map<String, dynamic>?) ?? {};
                  final authorId = userJson['id'] as String? ?? '';
                  final username = userJson['username'] as String? ?? '';
                  final avatarUrl = userJson['avatar_url'] as String?;

                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () => context.go('/users/$authorId'),
                      child: Column(
                        children: [
                          KotobaAvatar(imageUrl: avatarUrl, size: KotobaAvatarSize.lg),
                          const SizedBox(height: 8),
                          Text(username, style: KotobaTypography.labelSm),
                          Text('Autor', style: KotobaTypography.labelXs.copyWith(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildCard({required String title, required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: KotobaTypography.labelMd.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}
