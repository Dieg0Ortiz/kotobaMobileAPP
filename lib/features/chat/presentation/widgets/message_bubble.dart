import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    final timeStr = DateFormat('HH:mm').format(message.createdAt);

    if (message.isWorkShare) {
      return _WorkShareBubble(message: message, isMe: isMe);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? c.primary : c.surfaceHigh,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: Text(
                message.content,
                style: KotobaTypography.bodyMd.copyWith(
                  color: isMe ? c.onPrimary : c.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeStr,
              style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkShareBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _WorkShareBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    final meta = message.metadata ?? {};
    final workId = meta['work_id'] as String?;
    final workTitle = meta['work_title'] as String? ?? 'Obra compartida';
    final coverUrl = meta['cover_url'] as String?;
    final timeStr = DateFormat('HH:mm').format(message.createdAt);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isMe ? c.primary.withOpacity(0.15) : c.surfaceHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isMe ? c.primary.withOpacity(0.3) : c.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (coverUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: coverUrl,
                        width: 48,
                        height: 64,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 48,
                          height: 64,
                          color: c.surfaceHigh,
                          child: Icon(Icons.book, color: c.onSurfaceVariant, size: 24),
                        ),
                      ),
                    ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          workTitle,
                          style: KotobaTypography.bodyMd.copyWith(
                            color: isMe ? c.primary : c.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeStr,
              style: KotobaTypography.labelXs.copyWith(color: c.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
