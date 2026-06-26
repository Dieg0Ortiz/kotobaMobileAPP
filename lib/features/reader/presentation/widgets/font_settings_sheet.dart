import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../providers/reader_providers.dart';

class FontSettingsSheet extends ConsumerWidget {
  const FontSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readerPreferencesProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.fontSettings, style: KotobaTypography.headlineMd),
          const SizedBox(height: 24),
          Text(AppStrings.fontSize, style: KotobaTypography.labelSm),
          Slider(
            value: prefs.fontSize,
            min: 14,
            max: 32,
            divisions: 9,
            activeColor: AppColors.primary,
            onChanged: (v) =>
                ref.read(readerPreferencesProvider.notifier).setFontSize(v),
          ),
          const SizedBox(height: 16),
          Text(AppStrings.fontFamily, style: KotobaTypography.labelSm),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FontChip(
                label: 'Serif',
                fontFamily: 'Source Serif 4',
                isSelected: prefs.fontFamily == 'Source Serif 4',
                onTap: () => ref
                    .read(readerPreferencesProvider.notifier)
                    .setFontFamily('Source Serif 4'),
              ),
              _FontChip(
                label: 'Sans Serif',
                fontFamily: 'DM Sans',
                isSelected: prefs.fontFamily == 'DM Sans',
                onTap: () => ref
                    .read(readerPreferencesProvider.notifier)
                    .setFontFamily('DM Sans'),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FontChip extends StatelessWidget {
  final String label;
  final String fontFamily;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontChip({
    required this.label,
    required this.fontFamily,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
