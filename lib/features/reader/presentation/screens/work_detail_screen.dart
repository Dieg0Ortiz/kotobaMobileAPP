import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_chip.dart';
import '../../../../core/widgets/common/kotoba_loading.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../domain/entities/comment.dart';
import '../providers/reader_providers.dart';

class WorkDetailScreen extends ConsumerWidget {
  final String workId;

  const WorkDetailScreen({required this.workId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(workDetailViewModelProvider(workId));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0F),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () { if (context.canPop()) context.pop(); },
          ),
          title: Text(
            'Kotoba',
            style: KotobaTypography.labelSm.copyWith(
              color: AppColors.primary,
              fontSize: 14,
              letterSpacing: 0.08,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
        ),
        body: stateAsync.when(
          loading: () => const Center(child: KotobaLoading()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (state) {
            final work = state.work;
            final chapters = state.chapters;

            final profileAsync = ref.watch(currentProfileProvider);
            final currentUserId = profileAsync.maybeWhen(
              data:   (u) => u.id,
              orElse: () => '',
            );
            final isAuthor = currentUserId.isNotEmpty && currentUserId == work.authorId;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _HeroSection(work: work, isAuthor: isAuthor, workId: workId),
                ),
                SliverToBoxAdapter(
                  child: _StatsBar(work: work),
                ),
                SliverToBoxAdapter(
                  child: _ActionBar(
                    work: work,
                    chapters: chapters,
                    workId: workId,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _SynopsisSection(work: work),
                ),
                SliverToBoxAdapter(
                  child: _ChapterIndexSection(
                    chapters: chapters,
                    workId: workId,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _CommunitySection(workId: workId),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Hero Section ────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final dynamic work;
  final bool isAuthor;
  final String workId;

  const _HeroSection({
    required this.work,
    required this.isAuthor,
    required this.workId,
  });

  @override
  Widget build(BuildContext context) {
    final tags = <String>{work.genre};
    for (final t in (work.tags as List<dynamic>? ?? [])) {
      tags.add(t.toString());
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (work.coverUrl != null)
            CachedNetworkImage(
              imageUrl: work.coverUrl!,
              fit: BoxFit.cover,
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xFF0D0D0F),
                ],
                stops: [0.4, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.take(3).map((t) => KotobaChip(
                    label: t,
                  )).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  work.title,
                  style: const TextStyle(
                    fontFamily: 'Noto Serif JP',
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.edit, size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: work.authorId != null && work.authorId.isNotEmpty
                          ? () => context.push('/users/${work.authorId}')
                          : null,
                      child: Text(
                        'Por ${work.authorName.isNotEmpty ? work.authorName : 'Autor'}',
                        style: KotobaTypography.bodyMd.copyWith(
                          color: AppColors.primaryContainer,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isAuthor)
            Positioned(
              top: 60,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/write/edit/$workId'),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Stats Bar ───────────────────────────────────────────────────────────────

class _StatsBar extends ConsumerWidget {
  final dynamic work;

  const _StatsBar({required this.work});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voteAsync = ref.watch(myVoteProvider(work.id));
    final currentVote = voteAsync.maybeWhen(data: (v) => v, orElse: () => 0);
    
    int displayVotes = work.ratingCount;
    if (displayVotes == 0 && currentVote != 0) {
      displayVotes = 1;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
          bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _StatItem(value: work.formattedViewCount, label: 'Lecturas')),
          Container(width: 1, height: 32, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          Expanded(child: _StatItem(value: displayVotes.toString(), label: 'Votos')),
          Container(width: 1, height: 32, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          Expanded(child: _StatItem(value: work.chapterCount.toString(), label: 'Capítulos')),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Noto Serif JP',
            fontSize: 28,
            fontWeight: FontWeight.w500,
            height: 1.1,
            color: AppColors.primaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: KotobaTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

// ── Action Bar ──────────────────────────────────────────────────────────────

class _ActionBar extends ConsumerWidget {
  final dynamic work;
  final List<dynamic> chapters;
  final String workId;

  const _ActionBar({
    required this.work,
    required this.chapters,
    required this.workId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voteAsync = ref.watch(myVoteProvider(workId));
    final bookmarkAsync = ref.watch(myBookmarkProvider(workId));
    final currentVote = voteAsync.maybeWhen(data: (v) => v, orElse: () => 0);
    final isBookmarked = bookmarkAsync.maybeWhen(data: (b) => b, orElse: () => false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () {
                  if (chapters.isNotEmpty) {
                    context.push('/works/$workId/chapters/${chapters.first.id}');
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.book, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'LEER AHORA',
                      style: KotobaTypography.labelMd.copyWith(
                        color: AppColors.onPrimary,
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 52,
            height: 52,
            child: OutlinedButton(
              onPressed: () async {
                final repo = ref.read(contentRepositoryProvider);
                final Map<String, dynamic> stats;
                if (currentVote != 0) {
                  stats = await repo.unvoteWork(workId).then((r) => r.fold((_) => <String, dynamic>{}, (d) => d));
                } else {
                  stats = await repo.voteWork(workId, 1).then((r) => r.fold((_) => <String, dynamic>{}, (d) => d));
                }
                ref.invalidate(myVoteProvider(workId));
                
                // Invalidate catalog providers so the Home screen updates with the new vote count
                ref.invalidate(trendingWorksProvider);
                ref.invalidate(recommendedWorksProvider);
                
                final viewModel = ref.read(workDetailViewModelProvider(workId).notifier);
                
                if (stats.containsKey('rating_count')) {
                  viewModel.updateVoteStats(
                    (stats['rating'] as num?)?.toDouble() ?? work.rating,
                    (stats['rating_count'] as int?) ?? work.ratingCount,
                  );
                } else {
                  final newCount = work.ratingCount + (currentVote != 0 ? -1 : 1);
                  viewModel.updateVoteStats(work.rating, newCount < 0 ? 0 : newCount);
                }
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: currentVote != 0 ? AppColors.primaryContainer.withValues(alpha: 0.2) : AppColors.surfaceHigh,
                foregroundColor: currentVote != 0 ? AppColors.primary : AppColors.primaryContainer,
                side: BorderSide(
                  color: currentVote != 0 ? AppColors.primary.withValues(alpha: 0.4) : AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Icon(currentVote != 0 ? Icons.thumb_up : Icons.thumb_up_outlined),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 52,
            height: 52,
            child: OutlinedButton(
              onPressed: () async {
                final repo = ref.read(contentRepositoryProvider);
                if (isBookmarked) {
                  await repo.unbookmarkWork(workId);
                } else {
                  await repo.bookmarkWork(workId);
                }
                ref.invalidate(myBookmarkProvider(workId));
                ref.invalidate(myBookmarksProvider);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: isBookmarked ? AppColors.primaryContainer.withValues(alpha: 0.2) : AppColors.surfaceHigh,
                foregroundColor: isBookmarked ? AppColors.primary : AppColors.primaryContainer,
                side: BorderSide(
                  color: isBookmarked ? AppColors.primary.withValues(alpha: 0.4) : AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Synopsis Section ────────────────────────────────────────────────────────

class _SynopsisSection extends StatelessWidget {
  final dynamic work;

  const _SynopsisSection({required this.work});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(label: AppStrings.synopsis),
          const SizedBox(height: 16),
          _GlassQuote(text: work.synopsis),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _GlassQuote extends StatelessWidget {
  final String text;

  const _GlassQuote({required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF131318).withValues(alpha: 0.8),
          border: Border(
            left: const BorderSide(color: AppColors.primaryContainer, width: 4),
            top: BorderSide(color: AppColors.primaryContainer.withValues(alpha: 0.2)),
            right: BorderSide(color: AppColors.primaryContainer.withValues(alpha: 0.2)),
            bottom: BorderSide(color: AppColors.primaryContainer.withValues(alpha: 0.2)),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -8,
              left: -4,
              child: Icon(
                Icons.format_quote,
                size: 48,
                color: AppColors.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                text,
                style: KotobaTypography.pullQuote.copyWith(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chapter Index Section ───────────────────────────────────────────────────

class _ChapterIndexSection extends StatefulWidget {
  final List<dynamic> chapters;
  final String workId;

  const _ChapterIndexSection({
    required this.chapters,
    required this.workId,
  });

  @override
  State<_ChapterIndexSection> createState() => _ChapterIndexSectionState();
}

class _ChapterIndexSectionState extends State<_ChapterIndexSection> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    const previewCount = 3;
    final limit = _showAll ? widget.chapters.length : previewCount;
    final displayed = widget.chapters.take(limit).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionHeader(label: AppStrings.chapterIndex),
              if (widget.chapters.length > previewCount)
                TextButton(
                  onPressed: () => setState(() => _showAll = !_showAll),
                  child: Text(
                    _showAll ? 'Ver menos' : 'Ver Todos (${widget.chapters.length})',
                    style: KotobaTypography.labelSm.copyWith(
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...displayed.map((ch) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ChapterItem(
              chapter: ch,
              onTap: () => context.push('/works/${widget.workId}/chapters/${ch.id}'),
            ),
          )),
        ],
      ),
    );
  }
}

class _ChapterItem extends StatelessWidget {
  final dynamic chapter;
  final VoidCallback onTap;

  const _ChapterItem({required this.chapter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final locked = chapter.isLocked == true;

    return GestureDetector(
      onTap: locked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                chapter.number.toString().padLeft(2, '0'),
                style: KotobaTypography.headlineMd.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: KotobaTypography.bodyMd.copyWith(
                      color: locked
                          ? AppColors.onSurfaceVariant.withValues(alpha: 0.5)
                          : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              locked ? Icons.lock_outline : Icons.play_arrow,
              size: 20,
              color: locked
                  ? AppColors.outlineVariant
                  : AppColors.primaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Community Section ────────────────────────────────────────────────────────

class _CommunitySection extends ConsumerWidget {
  final String workId;

  const _CommunitySection({required this.workId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(workCommentsProvider(workId));
    final isAuthenticated = ref.watch(authStateProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(label: 'Comunidad'),
          const SizedBox(height: 16),
          // Comment input
          if (isAuthenticated)
            _CommentInput(workId: workId)
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Inicia sesión para comentar',
                style: KotobaTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          // Comments list
          commentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: KotobaLoading()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Error al cargar comentarios',
                style: KotobaTypography.bodyMd.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            data: (comments) {
              if (comments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Sé el primero en comentar',
                      style: KotobaTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: comments.map((c) => _CommentTile(comment: c)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends ConsumerStatefulWidget {
  final String workId;

  const _CommentInput({required this.workId});

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<_CommentInput> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    final repo = ref.read(contentRepositoryProvider);
    final result = await repo.createComment(widget.workId, text);
    setState(() => _submitting = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) {
        _controller.clear();
        ref.invalidate(workCommentsProvider(widget.workId));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: 3,
              minLines: 1,
              style: KotobaTypography.bodyMd.copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Escribe un comentario...',
                hintStyle: KotobaTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                filled: true,
                fillColor: AppColors.surfaceLow,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 40,
            width: 40,
            child: IconButton(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              color: AppColors.primary,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceLow,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF131318).withValues(alpha: 0.6),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: comment.avatarUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: comment.avatarUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.onSurfaceVariant,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          comment.username ?? 'Usuario',
                          style: KotobaTypography.labelMd.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          comment.timeAgo,
                          style: KotobaTypography.labelSm.copyWith(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment.content,
                      style: KotobaTypography.bodyMd.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared Widgets ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: KotobaTypography.labelSm.copyWith(
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
