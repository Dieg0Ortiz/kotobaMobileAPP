import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_button.dart';
import '../../../../core/widgets/common/kotoba_text_field.dart';
import '../providers/auth_providers.dart';

const _countries = [
  'México', 'Argentina', 'Colombia', 'Chile', 'Perú',
  'Ecuador', 'Venezuela', 'Bolivia', 'Paraguay', 'Uruguay',
  'Costa Rica', 'El Salvador', 'Guatemala', 'Honduras', 'Nicaragua',
  'Panamá', 'República Dominicana', 'Cuba', 'Puerto Rico',
  'España', 'Estados Unidos', 'Brasil', 'Otro',
];

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerState = ref.watch(registerViewModelProvider);

    ref.listen(registerViewModelProvider, (_, next) {
      next.whenOrNull(
        data: (_) => context.go('/home'),
        error: (err, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.toString())),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/auth/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                AppStrings.registerTitle,
                style: KotobaTypography.headlineLg,
              ),
              const SizedBox(height: 8),
              Text(
                'Únete a la comunidad literaria de Kotoba',
                style: KotobaTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),

              KotobaTextField(
                label: AppStrings.usernameLabel,
                prefixIcon: Icons.person_outline,
                onChanged: (v) => ref
                    .read(registerViewModelProvider.notifier)
                    .updateUsername(v),
              ),
              const SizedBox(height: 16),
              KotobaTextField(
                label: AppStrings.emailLabel,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                onChanged: (v) => ref
                    .read(registerViewModelProvider.notifier)
                    .updateEmail(v),
              ),
              const SizedBox(height: 16),
              KotobaTextField(
                label: AppStrings.passwordLabel,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                onChanged: (v) => ref
                    .read(registerViewModelProvider.notifier)
                    .updatePassword(v),
              ),
              const SizedBox(height: 16),
              KotobaTextField(
                label: 'Edad',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.cake_outlined,
                onChanged: (v) => ref
                    .read(registerViewModelProvider.notifier)
                    .updateAge(v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: null,
                decoration: const InputDecoration(
                  labelText: 'País',
                  prefixIcon: Icon(Icons.public_outlined),
                  border: UnderlineInputBorder(),
                ),
                style: KotobaTypography.bodyMd,
                dropdownColor: AppColors.surfaceHigh,
                items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) {
                  if (v != null) {
                    ref.read(registerViewModelProvider.notifier).updateCountry(v);
                  }
                },
              ),
              const SizedBox(height: 32),

              KotobaButton(
                label: AppStrings.registerButton,
                onPressed: registerState.isLoading
                    ? null
                    : () =>
                        ref.read(registerViewModelProvider.notifier).submit(),
                isLoading: registerState.isLoading,
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.hasAccount, style: KotobaTypography.labelSm),
                  TextButton(
                    onPressed: () => context.go('/auth/login'),
                    child: Text(
                      'Inicia sesión',
                      style: KotobaTypography.labelSm.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
