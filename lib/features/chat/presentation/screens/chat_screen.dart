import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/chat_providers.dart';
import '../widgets/message_bubble.dart';
import '../../domain/entities/message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _otherUsername;
  String? _otherAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadOtherParticipant();
    _markAsRead();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOtherParticipant() async {
    try {
      final api = ref.read(chatApiClientProvider);
      final result = await api.get<Map<String, dynamic>>(
        '/conversations/${widget.conversationId}/participant',
      );
      result.fold(
        (_) {},
        (data) {
          if (mounted) {
            setState(() {
              _otherUsername = data['username'] as String?;
              _otherAvatarUrl = data['avatar_url'] as String?;
            });
          }
        },
      );
    } catch (_) {}
  }

  Future<void> _markAsRead() async {
    final repo = ref.read(chatRepositoryProvider);
    await repo.markAsRead(widget.conversationId);
    ref.invalidate(conversationsProvider);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    final repo = ref.read(chatRepositoryProvider);
    await repo.sendMessage(widget.conversationId, text);
    ref.invalidate(messagesProvider(widget.conversationId));
    ref.invalidate(conversationsProvider);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: c.surfaceHigh,
              backgroundImage: _otherAvatarUrl != null
                  ? CachedNetworkImageProvider(_otherAvatarUrl!)
                  : null,
              child: _otherAvatarUrl == null
                  ? Text(
                      (_otherUsername ?? '?')[0].toUpperCase(),
                      style: KotobaTypography.labelMd.copyWith(color: c.onSurface),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(_otherUsername ?? 'Chat', style: KotobaTypography.labelMd),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (msgs) {
                if (msgs.isEmpty) {
                  return Center(
                    child: Text(
                      'Envía el primer mensaje',
                      style: KotobaTypography.bodyMd.copyWith(color: c.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final msg = msgs[index];
                    final isMe = msg.senderId == currentUserId;
                    return MessageBubble(message: msg, isMe: isMe);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(top: BorderSide(color: c.outlineVariant)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: c.primary),
                    onPressed: () => _showShareWorkSheet(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: KotobaTypography.bodyMd.copyWith(color: c.onSurfaceVariant),
                        filled: true,
                        fillColor: c.surfaceHigh,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: KotobaTypography.bodyMd.copyWith(color: c.onSurface),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: c.primary),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareWorkSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ShareWorkSheet(
        conversationId: widget.conversationId,
        onWorkSelected: (workId, workTitle, coverUrl) async {
          final repo = ref.read(chatRepositoryProvider);
          await repo.sendMessage(
            widget.conversationId,
            'Compartió una obra',
            messageType: 'work_share',
            metadata: {
              'work_id': workId,
              'work_title': workTitle,
              'cover_url': coverUrl,
            },
          );
          ref.invalidate(messagesProvider(widget.conversationId));
          ref.invalidate(conversationsProvider);
          _scrollToBottom();
        },
      ),
    );
  }
}

class _ShareWorkSheet extends ConsumerWidget {
  final String conversationId;
  final void Function(String workId, String workTitle, String? coverUrl) onWorkSelected;

  const _ShareWorkSheet({required this.conversationId, required this.onWorkSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = KotobaColors.of(context);
    final profileAsync = ref.watch(currentProfileProvider);

    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Compartir obra', style: KotobaTypography.labelMd),
          const SizedBox(height: 16),
          Expanded(
            child: profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (user) {
                if (user.id.isEmpty) return const SizedBox();

                final worksAsync = ref.watch(myWorksProvider(user.id));
                return worksAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error cargando obras')),
                  data: (works) {
                    if (works.isEmpty) {
                      return Center(
                        child: Text(
                          'No tienes obras aún',
                          style: KotobaTypography.bodyMd.copyWith(color: c.onSurfaceVariant),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: works.length,
                      itemBuilder: (context, index) {
                        final work = works[index];
                        return _WorkTile(
                          work: work,
                          onTap: () {
                            Navigator.pop(context);
                            onWorkSelected(work.id, work.title, work.coverUrl);
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkTile extends StatelessWidget {
  final Work work;
  final VoidCallback onTap;

  const _WorkTile({required this.work, required this.onTap});

  String _statusLabel(String status) {
    switch (status) {
      case 'ongoing': return 'En curso';
      case 'completed': return 'Finalizada';
      case 'hiatus': return 'Hiatus';
      case 'draft': return 'Borrador';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: work.coverUrl != null
            ? CachedNetworkImage(
                imageUrl: work.coverUrl!,
                width: 44,
                height: 60,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _placeholder(c),
              )
            : _placeholder(c),
      ),
      title: Text(
        work.title,
        style: KotobaTypography.labelMd.copyWith(color: c.onSurface),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${work.chapterCount} capítulos · ${_statusLabel(work.status)}',
        style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant),
      ),
      trailing: Icon(Icons.chevron_right, color: c.onSurfaceVariant, size: 20),
    );
  }

  Widget _placeholder(KotobaColors c) => Container(
    width: 44,
    height: 60,
    color: c.surfaceHigh,
    child: Icon(Icons.book, color: c.onSurfaceVariant, size: 20),
  );
}
