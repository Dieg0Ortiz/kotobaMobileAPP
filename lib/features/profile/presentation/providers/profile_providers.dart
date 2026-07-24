import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/domain/entities/work.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/i_profile_repository.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return ProfileRepositoryImpl(api);
});

final currentProfileProvider = FutureProvider<User>((ref) async {
  final isLoggedIn = ref.watch(authStateProvider);
  if (!isLoggedIn) throw Exception('Not authenticated');
  final repo = ref.read(profileRepositoryProvider);
  final result = await repo.getProfile('me');
  return result.fold((f) => throw f, (user) => user);
});

final authorDashboardProvider = FutureProvider<DashboardStats>((ref) async {
  final user = await ref.watch(currentProfileProvider.future);
  final repo = ref.read(profileRepositoryProvider);
  final result = await repo.getAuthorStats(user.id);
  return result.fold((f) => throw f, (stats) => stats);
});

final userWorksProvider = FutureProvider.family<List<Work>, String>((ref, userId) async {
  final repo = ref.read(workRepositoryProvider);
  final result = await repo.getWorksByAuthor(userId);
  return result.fold((f) => throw f, (works) => works);
});

final followingAuthorsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  final result = await repo.getFollowingAuthors();
  return result.fold((f) => throw f, (data) => data);
});

final publicAuthorProfileProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final repo = ref.read(profileRepositoryProvider);
  final result = await repo.getAuthorProfile(userId);
  return result.fold((f) => throw f, (data) => data);
});

final newAuthorsProvider = FutureProvider<List<User>>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  final result = await repo.getNewAuthors();
  return result.fold((f) => throw f, (authors) => authors);
});

// ── Balance / Income from Payment Service ──────────────────────
final balanceProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(paymentApiClientProvider);
  final result = await api.get('/payments/balance');
  return result.fold(
    (f) => throw f,
    (data) => data is Map<String, dynamic> ? data : {},
  );
});

final requestPayoutProvider = FutureProvider<String>((ref) async {
  final api = ref.read(paymentApiClientProvider);
  final result = await api.post<Map<String, dynamic>>('/payments/payout', data: {});
  return result.fold(
    (f) => throw f,
    (data) => data['message'] as String? ?? 'Pago procesado',
  );
});
