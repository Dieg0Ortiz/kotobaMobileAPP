import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../providers/subscription_providers.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  static const _plans = [
    {
      'id': 'P-8JK586133K777423TNJUH47I',
      'name': 'Premium',
      'price': r'$4.99',
      'period': '/mes',
      'features': [
        'Insignia Premium en tu perfil',
        'Acceso al Dashboard de autor',
        'Acceso anticipado a capítulos',
        'Sin anuncios',
      ],
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = KotobaColors.of(context);
    final statusAsync = ref.watch(subscriptionStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Suscríbete', style: KotobaTypography.headlineMd),
        centerTitle: false,
      ),
      body: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (status) {
          final isActive = status?['active'] == true;
          final sub = status?['subscription'] as Map<String, dynamic>?;

          if (isActive && sub != null) {
            return _ActiveSubscriptionView(
              subscription: sub,
              onCancel: () async {
                final ok = await ref.read(cancelSubscriptionProvider.future);
                if (ok && context.mounted) {
                  ref.invalidate(subscriptionStatusProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Suscripción cancelada')),
                  );
                }
              },
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 16),
              Text(
                'Apoya a Kotoba',
                style: KotobaTypography.headlineMd.copyWith(color: c.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Obtén Premium para desbloquear beneficios exclusivos y apoyar a Kotoba.',
                style: KotobaTypography.bodyMd.copyWith(color: c.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              for (final plan in _plans) ...[
                _PlanCard(
                  plan: plan,
                  onSubscribe: () => _subscribe(ref, context, plan['id'] as String),
                ),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _subscribe(WidgetRef ref, BuildContext context, String planId) async {
    final api = ref.read(paymentApiProvider);
    final result = await api.post<Map<String, dynamic>>(
      '/payments/subscription/create',
      data: {'planId': planId},
    );

    result.fold(
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          );
        }
      },
      (data) async {
        final url = data['approvalUrl'] as String?;
        if (url != null && context.mounted) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final VoidCallback onSubscribe;

  const _PlanCard({required this.plan, required this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan['name'] as String,
              style: KotobaTypography.labelMd.copyWith(color: c.primary),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan['price'] as String,
                  style: KotobaTypography.headlineMd.copyWith(
                    color: c.onSurface,
                    fontSize: 32,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    plan['period'] as String,
                    style: KotobaTypography.bodyMd.copyWith(color: c.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final feature in (plan['features'] as List<String>)) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: c.primary, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    feature,
                    style: KotobaTypography.bodyMd.copyWith(color: c.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Suscribirse',
                  style: KotobaTypography.labelMd.copyWith(color: c.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveSubscriptionView extends StatelessWidget {
  final Map<String, dynamic> subscription;
  final VoidCallback onCancel;

  const _ActiveSubscriptionView({
    required this.subscription,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: 64, color: c.primary),
            const SizedBox(height: 16),
            Text(
              'Premium activo',
              style: KotobaTypography.headlineMd.copyWith(color: c.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              '$4.99/mes',
              style: KotobaTypography.bodyMd.copyWith(color: c.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Gracias por apoyar a Kotoba',
              style: KotobaTypography.labelSm.copyWith(color: c.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: c.error),
                foregroundColor: c.error,
              ),
              child: const Text('Cancelar suscripción'),
            ),
          ],
        ),
      ),
    );
  }
}
