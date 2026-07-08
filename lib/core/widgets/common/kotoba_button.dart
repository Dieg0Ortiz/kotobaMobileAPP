import 'package:flutter/material.dart';

import '../../theme/kotoba_colors.dart';

/// Botón de Kotoba con tres variantes: action, primary, ghost.
///
/// - **action** (Terracota): CTAs de máxima prioridad — "Comenzar a leer",
///   "Publicar", "Seguir".
/// - **primary** (Gold): CTAs secundarios — "Apoyar al autor", "Nuevo Capítulo".
/// - **ghost** (Outline): Acciones terciarias — "Cargar más", "Ver todos".
enum KotobaButtonVariant { action, primary, ghost }

class KotobaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final KotobaButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;

  const KotobaButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = KotobaButtonVariant.action,
    this.icon,
    this.fullWidth = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    final child = isLoading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: c.onSurface,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.05,
                  ),
                ),
              ),
            ],
          );

    final style = _buttonStyle(c);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48,
      child: variant == KotobaButtonVariant.ghost
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: style,
              child: child,
            )
          : FilledButton(
              onPressed: isLoading ? null : onPressed,
              style: style,
              child: child,
            ),
    );
  }

  ButtonStyle _buttonStyle(KotobaColors c) {
    switch (variant) {
      case KotobaButtonVariant.action:
        return FilledButton.styleFrom(
          backgroundColor: c.actionContainer,
          foregroundColor: c.onAction,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      case KotobaButtonVariant.primary:
        return FilledButton.styleFrom(
          backgroundColor: c.primaryContainer,
          foregroundColor: c.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      case KotobaButtonVariant.ghost:
        return OutlinedButton.styleFrom(
          foregroundColor: c.onSurface,
          side: BorderSide(color: c.outline, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
    }
  }
}
