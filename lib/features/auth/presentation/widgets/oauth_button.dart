import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_providers.dart';

/// Proveedor de OAuth soportado.
enum OAuthProvider { google, discord }

/// Botón de OAuth.
class OAuthButton extends ConsumerWidget {
  final OAuthProvider provider;

  const OAuthButton({required this.provider, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (icon, label) = switch (provider) {
      OAuthProvider.google => (
          'G',
          AppStrings.continueWithGoogle,
        ),
      OAuthProvider.discord => (
          'D',
          AppStrings.continueWithDiscord,
        ),
    };

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          if (provider == OAuthProvider.discord) {
            ref.read(loginViewModelProvider.notifier).signInWithDiscord();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label — próximamente'),
                backgroundColor: AppColors.surfaceHigh,
              ),
            );
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                icon,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
