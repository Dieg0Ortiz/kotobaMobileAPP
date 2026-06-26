import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../../../../core/widgets/common/kotoba_pull_quote.dart';

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KotobaPullQuote(
            text: '"La tinta es la sangre de mundos que aún no existen."',
          ),
          const SizedBox(height: 16),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              widget.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: KotobaTypography.bodyMd,
            ),
            secondChild: Text(
              widget.text,
              style: KotobaTypography.bodyMd,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(
              _isExpanded ? 'MOSTRAR MENOS' : 'LEER MÁS',
              style: KotobaTypography.labelSm.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
