import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/kotoba_button.dart';
import '../../../../core/widgets/common/kotoba_text_field.dart';

/// Formulario de login — solo pinta, recibe callbacks.
class LoginForm extends StatelessWidget {
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;
  final bool isLoading;

  const LoginForm({
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        KotobaTextField(
          label: AppStrings.emailLabel,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: 16),
        KotobaTextField(
          label: AppStrings.passwordLabel,
          obscureText: true,
          prefixIcon: Icons.lock_outline,
          onChanged: onPasswordChanged,
        ),
        const SizedBox(height: 24),
        KotobaButton(
          label: AppStrings.loginButton,
          onPressed: isLoading ? null : onSubmit,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
