import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../providers/reader_providers.dart';

class FontSettingsSheet extends ConsumerWidget {
  const FontSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readerPreferencesProvider);
    final c = KotobaColors.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.fontSettings, style: KotobaTypography.headlineMd.copyWith(color: c.onSurface)),
          const SizedBox(height: 24),
          Text(AppStrings.fontSize, style: KotobaTypography.labelSm.copyWith(color: c.onSurfaceVariant)),
          Slider(
            value: prefs.fontSize,
            min: 14,
            max: 32,
            divisions: 9,
            activeColor: c.primary,
            onChanged: (v) =>
                ref.read(readerPreferencesProvider.notifier).setFontSize(v),
          ),
          const SizedBox(height: 16),
          Text(AppStrings.fontFamily, style: KotobaTypography.labelSm.copyWith(color: c.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FontChip(
                label: 'Merriweather',
                fontFamily: 'Merriweather',
                isSelected: prefs.fontFamily == 'Merriweather',
                onTap: () => ref
                    .read(readerPreferencesProvider.notifier)
                    .setFontFamily('Merriweather'),
              ),
              _FontChip(
                label: 'Lora',
                fontFamily: 'Lora',
                isSelected: prefs.fontFamily == 'Lora',
                onTap: () => ref
                    .read(readerPreferencesProvider.notifier)
                    .setFontFamily('Lora'),
              ),
              _FontChip(
                label: 'Roboto',
                fontFamily: 'Roboto',
                isSelected: prefs.fontFamily == 'Roboto',
                onTap: () => ref
                    .read(readerPreferencesProvider.notifier)
                    .setFontFamily('Roboto'),
              ),
              _FontChip(
                label: 'Open Sans',
                fontFamily: 'Open Sans',
                isSelected: prefs.fontFamily == 'Open Sans',
                onTap: () => ref
                    .read(readerPreferencesProvider.notifier)
                    .setFontFamily('Open Sans'),
              ),
              _FontChip(
                label: 'Source Serif 4',
                fontFamily: 'Source Serif 4',
                isSelected: prefs.fontFamily == 'Source Serif 4',
                onTap: () => ref
                    .read(readerPreferencesProvider.notifier)
                    .setFontFamily('Source Serif 4'),
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
    final c = KotobaColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? c.primaryContainer : c.surfaceHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.getFont(
            fontFamily,
            fontSize: 16,
            color: isSelected ? c.onPrimary : c.onSurface,
          ),
        ),
      ),
    );
  }
}
