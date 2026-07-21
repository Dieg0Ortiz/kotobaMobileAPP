import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../catalog/domain/entities/work.dart';
import '../providers/profile_providers.dart';

class AuthorProfileScreen extends ConsumerWidget {
  final String userId;

  const AuthorProfileScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicAuthorProfileProvider(userId));
    final currentUserAsync = ref.watch(currentProfileProvider);
    final followingAsync = ref.watch(followingAuthorsProvider);
    final c = KotobaColors.of(context);
    final currentUserId = currentUserAsync.maybeWhen(
      data: (u) => u.id,
      orElse: () => '',
    );

    return Scaffold(
      backgroundColor: c.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () { if (context.canPop()) context.pop(); },
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: KotobaLoading()),
        error: (e, _) => Center(child: Text(e.toString(), style: TextStyle(color: c.onSurface))),
        data: (data) {
          try {
            final user = User.fromJson(data);
            final works = (data['works'] as List<dynamic>?)
                ?.map((w) => Work(
                      id: w['id'] as String,
                      title: w['title'] as String,
                      authorId: w['author_id'] as String? ?? '',
                      authorName: w['author_name'] as String? ?? user.username,
                      coverUrl: w['cover_url'] as String?,
                      synopsis: w['synopsis'] as String? ?? '',
                      genres: (w['genres'] as List<dynamic>?)?.cast<String>() ?? (w['genre'] != null ? [w['genre'] as String] : []),
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
                .where((w) => w.status != 'draft')
                .toList() ??
                [];
            final isFollowedInList = followingAsync.maybeWhen(
              data: (list) => list.any((a) => a['id'] == userId),
              orElse: () => false,
            );
            final isFollowedByMe = (data['is_followed_by_me'] as bool?) == true || isFollowedInList;
            final isMe = currentUserId == user.id;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _ProfileHeaderSection(
                  user: user,
                  worksLength: works.length,
                  isMe: isMe,
                  isFollowedByMe: isFollowedByMe,
                  onFollow: () async {
                    final repo = ref.read(profileRepositoryProvider);
                    final result = isFollowedByMe
                        ? await repo.unfollowUser(userId)
                        : await repo.followUser(userId);
                    result.fold(
                      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
                      (_) {
                        ref.invalidate(publicAuthorProfileProvider(userId));
                        ref.invalidate(followingAuthorsProvider);
                      },
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
                      style: KotobaTypography.headlineMd.copyWith(color: c.onSurface),
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final work = works[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(24, index == 0 ? 8 : 0, 24, 12),
                      child: SizedBox(
                        height: 120,
                        child: InkWell(
                          onTap: () => context.push('/works/${work.id}'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 72,
                                    height: 96,
                                    child: work.coverUrl != null
                                        ? Image.network(work.coverUrl!, fit: BoxFit.cover)
                                        : Container(
                                            color: c.primary.withValues(alpha: 0.2),
                                            child: Icon(Icons.book, color: c.primary),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(work.title, style: KotobaTypography.labelMd.copyWith(color: c.onSurface), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text('${work.chapterCount} capítulos', style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
        } catch (e, st) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Error: $e\n$st', style: TextStyle(color: c.onSurface)),
            ),
          );
        }
        },
      ),
    );
  }
}

class _ProfileHeaderSection extends StatefulWidget {
  final User user;
  final int worksLength;
  final bool isMe;
  final bool isFollowedByMe;
  final VoidCallback onFollow;

  const _ProfileHeaderSection({
    required this.user,
    required this.worksLength,
    required this.isMe,
    required this.isFollowedByMe,
    required this.onFollow,
  });

  @override
  State<_ProfileHeaderSection> createState() => _ProfileHeaderSectionState();
}

class _ProfileHeaderSectionState extends State<_ProfileHeaderSection> {
  late bool _isFollowed;
  late int _followersCount;

  @override
  void initState() {
    super.initState();
    _isFollowed = widget.isFollowedByMe;
    _followersCount = widget.user.followers;
  }

  @override
  void didUpdateWidget(covariant _ProfileHeaderSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFollowedByMe != widget.isFollowedByMe) {
      _isFollowed = widget.isFollowedByMe;
    }
    if (oldWidget.user.followers != widget.user.followers) {
      _followersCount = widget.user.followers;
    }
  }

  void _handleFollow() {
    setState(() {
      _isFollowed = !_isFollowed;
      _followersCount += _isFollowed ? 1 : -1;
    });
    widget.onFollow();
  }

  void _showSupportSheet(BuildContext context, User user) {
    final c = KotobaColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apoyar a @${user.username}', style: KotobaTypography.headlineMd.copyWith(color: c.onSurface)),
              const SizedBox(height: 16),
              Text(
                'Puedes enviar un tip vía PayPal al correo registrado por el autor.',
                style: KotobaTypography.bodyMd.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.paypalEmail ?? 'No disponible',
                        style: KotobaTypography.bodyMd.copyWith(color: c.onSurface),
                      ),
                    ),
                    if (user.paypalEmail != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Email copiado al portapapeles')),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: user.paypalEmail != null
                      ? () async {
                          final uri = Uri.parse('https://paypal.me/${user.paypalEmail!.split('@').first}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('No se pudo abrir PayPal')),
                              );
                            }
                          }
                        }
                      : null,
                  label: const Text('Abrir PayPal'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    return Stack(
      children: [
        // Banner Image
        if (widget.user.bannerUrl != null)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: widget.user.bannerUrl!,
              fit: BoxFit.cover,
            ),
          )
        else
          Positioned.fill(
            child: Container(color: c.surfaceHigh),
          ),

        // Gradient overlay for readability (darker at bottom)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  c.background.withValues(alpha: 0.5),
                  c.background.withValues(alpha: 0.95),
                  c.background,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // Content
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: c.background,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: widget.user.avatarUrl != null
                        ? CachedNetworkImageProvider(widget.user.avatarUrl!)
                        : null,
                    child: widget.user.avatarUrl == null
                        ? Icon(Icons.person, size: 48, color: c.onSurfaceVariant)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.user.fullName?.isNotEmpty == true ? widget.user.fullName! : widget.user.username,
                  style: KotobaTypography.headlineLg.copyWith(color: c.onSurface),
                ),
                const SizedBox(height: 4),
                const SizedBox(height: 4),
                Text(
                  '@${widget.user.username}',
                  style: KotobaTypography.labelMd.copyWith(color: c.onSurfaceVariant),
                ),
                if (widget.user.bio != null && widget.user.bio!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.user.bio!,
                      textAlign: TextAlign.center,
                      style: KotobaTypography.bodyMd.copyWith(color: c.onSurfaceVariant),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatColumn(value: '${widget.worksLength > 0 ? widget.worksLength : widget.user.worksCount}', label: 'OBRAS'),
                    const SizedBox(width: 32),
                    _StatColumn(value: '$_followersCount', label: 'SEGUIDORES'),
                    const SizedBox(width: 32),
                    _StatColumn(value: '${widget.user.following}', label: 'SIGUIENDO'),
                  ],
                ),
                const SizedBox(height: 20),
                if (!widget.isMe)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: _isFollowed
                              ? OutlinedButton(
                                  onPressed: _handleFollow,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: c.onSurface,
                                    side: BorderSide(color: c.outlineVariant),
                                  ),
                                  child: const Text('Siguiendo'),
                                )
                              : FilledButton(
                                  onPressed: _handleFollow,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: c.primary,
                                    foregroundColor: c.onPrimary,
                                  ),
                                  child: const Text('Seguir'),
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.favorite_border, size: 18),
                          onPressed: () => _showSupportSheet(context, widget.user),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: c.onSurface,
                            side: BorderSide(color: c.outlineVariant),
                          ),
                          label: const Text('Apoyar'),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                Divider(color: c.outlineVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    return Column(
      children: [
        Text(value, style: KotobaTypography.headlineMd.copyWith(color: c.onSurface)),
        const SizedBox(height: 4),
        Text(label, style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant, letterSpacing: 1)),
      ],
    );
  }
}
