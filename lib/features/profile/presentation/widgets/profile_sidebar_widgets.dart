import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_avatar.dart';
import '../providers/profile_providers.dart';

class SimilarAuthorsCard extends ConsumerWidget {
  const SimilarAuthorsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(followingAuthorsProvider);
    final c = KotobaColors.of(context);

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
                      color: c.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: c.onSurfaceVariant),
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
                      onTap: () => context.push('/users/$authorId'),
                      child: Column(
                        children: [
                          KotobaAvatar(imageUrl: avatarUrl, size: KotobaAvatarSize.lg),
                          const SizedBox(height: 8),
                          Text(username, style: KotobaTypography.labelSm.copyWith(color: c.onSurface)),
                          Text('Autor', style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant)),
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


