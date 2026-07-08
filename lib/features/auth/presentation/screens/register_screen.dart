import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/kotoba_colors.dart';
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
    final c = KotobaColors.of(context);

    ref.listen(registerViewModelProvider, (_, next) {
      next.whenOrNull(
        data: (_) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: c.surface,
              title: const Text('Cuenta creada'),
              content: const Text('Revisa tu correo electrónico para confirmar la cuenta antes de iniciar sesión.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.go('/auth/login');
                  },
                  child: const Text('Ir a iniciar sesión'),
                ),
              ],
            ),
          );
        },
        error: (err, _) {
          final msg = err is String ? err : err.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $msg')),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () { if (context.canPop()) context.pop(); },
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
                style: KotobaTypography.headlineLg.copyWith(color: c.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Únete a la comunidad literaria de Kotoba',
                style: KotobaTypography.bodyMd.copyWith(
                  color: c.onSurfaceVariant,
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
                style: KotobaTypography.bodyMd.copyWith(color: c.onSurface),
                dropdownColor: c.surfaceHigh,
                items: _countries.map((country) => DropdownMenuItem(value: country, child: Text(country))).toList(),
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
                  Text(AppStrings.hasAccount, style: KotobaTypography.labelSm.copyWith(color: c.onSurfaceVariant)),
                  TextButton(
                    onPressed: () => context.go('/auth/login'),
                    child: Text(
                      'Inicia sesión',
                      style: KotobaTypography.labelSm.copyWith(
                        color: c.primary,
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
