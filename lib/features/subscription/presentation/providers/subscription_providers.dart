import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final paymentApiProvider = Provider<ApiClient>((ref) {
  return ref.read(paymentApiClientProvider);
});

final subscriptionStatusProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final api = ref.read(paymentApiProvider);
  final result = await api.get<Map<String, dynamic>>('/payments/subscription/me');
  return result.fold((_) => null, (data) => data);
});

final createSubscriptionProvider = FutureProvider.autoDispose.family<Map<String, dynamic>?, String>((ref, planId) async {
  final api = ref.read(paymentApiProvider);
  final result = await api.post<Map<String, dynamic>>('/payments/subscription/create', data: {'planId': planId});
  return result.fold((_) => null, (data) => data);
});

final cancelSubscriptionProvider = FutureProvider.autoDispose<bool>((ref) async {
  final api = ref.read(paymentApiProvider);
  final result = await api.post<Map<String, dynamic>>('/payments/subscription/cancel');
  return result.fold((_) => false, (_) => true);
});

final isPremiumProvider = FutureProvider.autoDispose<bool>((ref) async {
  final status = await ref.watch(subscriptionStatusProvider.future);
  return status?['active'] == true;
});
