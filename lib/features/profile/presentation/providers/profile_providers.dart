import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user.dart';
import '../../data/repositories/mock_profile_repository.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/i_profile_repository.dart';

// ── Repositorio ──────────────────────────────────────────────────
final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return MockProfileRepository();
});

// ── Providers ────────────────────────────────────────────────────
final currentProfileProvider = FutureProvider<User>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  // Simular request del usuario actual
  final result = await repo.getProfile('current');
  return result.fold((f) => throw f, (user) => user);
});

final authorDashboardProvider = FutureProvider<DashboardStats>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  final result = await repo.getAuthorStats('current');
  return result.fold((f) => throw f, (stats) => stats);
});
