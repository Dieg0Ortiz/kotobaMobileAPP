import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../catalog/domain/entities/work.dart';
import '../providers/profile_providers.dart';
import '../widgets/horizontal_work_card.dart';

final publicAuthorProfileProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final repo = ref.read(profileRepositoryProvider);
  final result = await repo.getAuthorProfile(userId);
  return result.fold((f) => throw f, (data) => data);
});

class AuthorProfileScreen extends ConsumerWidget {
  final String userId;

  const AuthorProfileScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicAuthorProfileProvider(userId));
    final currentUserAsync = ref.watch(currentProfileProvider);
    final currentUserId = currentUserAsync.maybeWhen(
      data: (u) => u.id,
      orElse: () => '',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (data) {
          final user = User.fromJson(data);
          final works = (data['works'] as List<dynamic>?)
              ?.map((w) => Work(
                    id: w['id'] as String,
                    title: w['title'] as String,
                    authorId: w['author_id'] as String? ?? '',
                    authorName: w['author_name'] as String? ?? user.username,
                    coverUrl: w['cover_url'] as String?,
                    synopsis: w['synopsis'] as String? ?? '',
                    genre: w['genre'] as String? ?? '',
                    tags: (w['tags'] as List<dynamic>?)?.cast<String>() ?? [],
                    status: w['status'] as String? ?? 'ongoing',
                    chapterCount: w['chapter_count'] as int? ?? 0,
                    wordCount: w['word_count'] as int? ?? 0,
                    viewCount: w['view_count'] as int? ?? 0,
                    rating: (w['rating'] as num?)?.toDouble() ?? 0,
                    ratingCount: w['rating_count'] as int? ?? 0,
                    publishedAt: DateTime.tryParse(w['published_at'] as String? ?? '') ?? DateTime.now(),
                    updatedAt: DateTime.tryParse(w['updated_at'] as String? ?? '') ?? DateTime.now(),
                  ))
              .toList() ??
              [];
          final isFollowedByMe = data['is_followed_by_me'] as bool? ?? false;
          final isMe = currentUserId == user.id;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _ProfileHeaderSection(
                  user: user,
                  isMe: isMe,
                  isFollowedByMe: isFollowedByMe,
                  onFollow: () async {
                    final repo = ref.read(profileRepositoryProvider);
                    final result = isFollowedByMe
                        ? await repo.unfollowUser(userId)
                        : await repo.followUser(userId);
                    result.fold(
                      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
                      (_) => ref.invalidate(publicAuthorProfileProvider(userId)),
                    );
                  },
                ),
              ),
              if (works.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Text(
                      'Historias de @${user.username}',
                      style: KotobaTypography.headlineMd,
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final work = works[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(24, index == 0 ? 8 : 0, 24, 12),
                      child: HorizontalWorkCard(
                        work: work,
                        onTap: () => context.go('/works/${work.id}'),
                      ),
                    );
                  },
                  childCount: works.length,
                ),
              ),
              if (works.isEmpty)
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(child: Text('Este autor aún no tiene historias publicadas')),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeaderSection extends StatelessWidget {
  final User user;
  final bool isMe;
  final bool isFollowedByMe;
  final VoidCallback onFollow;

  const _ProfileHeaderSection({
    required this.user,
    required this.isMe,
    required this.isFollowedByMe,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: user.avatarUrl != null
                ? CachedNetworkImageProvider(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? const Icon(Icons.person, size: 48, color: AppColors.onSurfaceVariant)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.username,
            style: KotobaTypography.headlineLg.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 4),
          if (user.bio != null && user.bio!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                user.bio!,
                textAlign: TextAlign.center,
                style: KotobaTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatColumn(value: '${user.worksCount}', label: 'OBRAS'),
              const SizedBox(width: 32),
              _StatColumn(value: '${user.followers}', label: 'SEGUIDORES'),
              const SizedBox(width: 32),
              _StatColumn(value: '${user.following}', label: 'SIGUIENDO'),
            ],
          ),
          const SizedBox(height: 20),
          if (!isMe)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: onFollow,
                style: FilledButton.styleFrom(
                  backgroundColor: isFollowedByMe ? AppColors.outlineVariant : AppColors.primary,
                  foregroundColor: isFollowedByMe ? AppColors.onSurface : AppColors.onPrimary,
                ),
                child: Text(isFollowedByMe ? 'Siguiendo' : 'Seguir'),
              ),
            ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.outlineVariant),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: KotobaTypography.headlineMd.copyWith(color: AppColors.onSurface)),
        const SizedBox(height: 4),
        Text(label, style: KotobaTypography.labelXs.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1)),
      ],
    );
  }
}
