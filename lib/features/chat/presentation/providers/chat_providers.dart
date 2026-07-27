import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/i_chat_repository.dart';

final chatApiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return ApiClient(storage, baseUrl: ApiConstants.chatBaseUrl);
});

final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  final api = ref.read(chatApiClientProvider);
  return ChatRepositoryImpl(api);
});

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final repo = ref.read(chatRepositoryProvider);
  final result = await repo.getConversations();
  return result.fold(
    (failure) => throw failure,
    (conversations) => conversations,
  );
});

final messagesProvider = FutureProvider.family<List<ChatMessage>, String>((ref, conversationId) async {
  final repo = ref.read(chatRepositoryProvider);
  final result = await repo.getMessages(conversationId);
  return result.fold(
    (failure) => throw failure,
    (messages) => messages,
  );
});

final chatRealtimeProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, conversationId) {
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser == null) return const Stream.empty();

  return Supabase.instance.client
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('conversation_id', conversationId)
      .order('created_at', ascending: false)
      .limit(1)
      .map((events) => events);
});

final totalUnreadProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(chatRepositoryProvider);
  final result = await repo.getConversations();
  return result.fold(
    (failure) => 0,
    (conversations) => conversations.fold<int>(0, (sum, c) => sum + c.unreadCount),
  );
});
