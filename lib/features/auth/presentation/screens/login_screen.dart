import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../providers/auth_providers.dart';
import '../widgets/login_form.dart';
import '../widgets/oauth_button.dart';

/// Pantalla de login.
///
/// Solo pinta. Delega toda la lógica al [LoginViewModel].
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginViewModelProvider);

    ref.listen(loginViewModelProvider, (_, next) {
      next.whenOrNull(
        data: (_) => context.go('/home'),
        error: (err, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err.toString()),
            backgroundColor: AppColors.errorContainer,
          ),
        ),
      );
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo
              Text(
                'Kotoba',
                style: KotobaTypography.displayXL.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '言葉',
                style: KotobaTypography.headlineMd.copyWith(
                  color: AppColors.primaryDim,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Tu historia, sin límites.',
                style: KotobaTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Formulario
              LoginForm(
                onEmailChanged: (e) =>
                    ref.read(loginViewModelProvider.notifier).updateEmail(e),
                onPasswordChanged: (p) =>
                    ref.read(loginViewModelProvider.notifier).updatePassword(p),
                onSubmit: () =>
                    ref.read(loginViewModelProvider.notifier).submit(),
                isLoading: loginState.isLoading,
              ),
              const SizedBox(height: 32),

              // Separador
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppStrings.orContinueWith,
                      style: KotobaTypography.labelXs,
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                ],
              ),
              const SizedBox(height: 24),

              // OAuth buttons (visual only)
              const OAuthButton(provider: OAuthProvider.google),
              const SizedBox(height: 12),
              const OAuthButton(provider: OAuthProvider.discord),
              const SizedBox(height: 32),

              // Link a registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.noAccount,
                    style: KotobaTypography.labelSm,
                  ),
                  TextButton(
                    onPressed: () => context.go('/auth/register'),
                    child: Text(
                      'Regístrate',
                      style: KotobaTypography.labelSm.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
