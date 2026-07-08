import 'package:flutter/material.dart';

import '../../theme/kotoba_colors.dart';

/// Chip para géneros y filtros con estilo pill del diseño Ink & Silence.
class KotobaChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const KotobaChip({
    required this.label,
    this.isSelected = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? c.primaryFixed : c.surfaceHigh,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? c.primaryContainer
                : c.outlineVariant,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? c.onPrimary : c.onSurface,
          ),
        ),
      ),
    );
  }
}
