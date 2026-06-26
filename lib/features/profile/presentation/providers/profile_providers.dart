import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/i_profile_repository.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return ProfileRepositoryImpl(api);
});

final currentProfileProvider = FutureProvider<User>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  final result = await repo.getProfile('me');
  return result.fold((f) => throw f, (user) => user);
});

final authorDashboardProvider = FutureProvider<DashboardStats>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  final result = await repo.getAuthorStats('current');
  return result.fold((f) => throw f, (stats) => stats);
});
