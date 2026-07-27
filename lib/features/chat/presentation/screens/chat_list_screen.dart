import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../providers/chat_providers.dart';
import '../../domain/entities/conversation.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final c = KotobaColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats', style: KotobaTypography.headlineMd),
        centerTitle: false,
      ),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (convos) {
          if (convos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: c.outlineVariant),
                  const SizedBox(height: 16),
                  Text('No hay conversaciones', style: KotobaTypography.bodyLg.copyWith(color: c.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Visita un perfil para iniciar un chat', style: KotobaTypography.labelSm.copyWith(color: c.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: convos.length,
            itemBuilder: (context, index) {
              final conv = convos[index];
              return _ConversationTile(conversation: conv);
            },
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    final hasUnread = conversation.unreadCount > 0;
    final timeStr = conversation.lastMessageAt != null
        ? _formatTime(conversation.lastMessageAt!)
        : '';

    return ListTile(
      onTap: () => context.push('/chat/${conversation.id}'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: c.surfaceHigh,
        backgroundImage: conversation.otherAvatarUrl != null
            ? CachedNetworkImageProvider(conversation.otherAvatarUrl!)
            : null,
        child: conversation.otherAvatarUrl == null
            ? Text(
                conversation.otherUsername.isNotEmpty
                    ? conversation.otherUsername[0].toUpperCase()
                    : '?',
                style: KotobaTypography.headlineMd.copyWith(color: c.onSurface),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.otherUsername,
              style: KotobaTypography.labelMd.copyWith(
                color: c.onSurface,
                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (timeStr.isNotEmpty)
            Text(
              timeStr,
              style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              conversation.lastMessage ?? 'Inicia la conversación',
              style: KotobaTypography.labelSm.copyWith(
                color: hasUnread ? c.onSurface : c.onSurfaceVariant,
                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasUnread)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: c.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: KotobaTypography.labelXs.copyWith(color: c.onPrimary),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) return DateFormat('dd/MM').format(time);
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Ahora';
  }
}
