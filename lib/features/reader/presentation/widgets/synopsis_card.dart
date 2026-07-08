import 'package:flutter/material.dart';

import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';

/// Tarjeta colapsable para la sinopsis de la obra.
class SynopsisCard extends StatefulWidget {
  final String text;

  const SynopsisCard({required this.text, super.key});

  @override
  State<SynopsisCard> createState() => _SynopsisCardState();
}

class _SynopsisCardState extends State<SynopsisCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              widget.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: KotobaTypography.bodyMd.copyWith(color: c.onSurface),
            ),
            secondChild: Text(
              widget.text,
              style: KotobaTypography.bodyMd.copyWith(color: c.onSurface),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(
              _isExpanded ? 'MOSTRAR MENOS' : 'LEER MÁS',
              style: KotobaTypography.labelSm.copyWith(
                color: c.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
