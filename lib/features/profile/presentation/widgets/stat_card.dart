import 'package:flutter/material.dart';

import '../../../../core/theme/kotoba_colors.dart';

/// Card para mostrar estadísticas en el dashboard.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? trend; // e.g., "+12%", "- 0"
  final bool isPositive;

  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.trend,
    this.isPositive = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    final trendColor = isPositive ? const Color(0xFFD9735A) : c.onSurfaceVariant; // Terracotta for positive

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceLowest, // White/clean background
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: c.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: c.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 20, color: const Color(0xFF735B28)), // Gold icon
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Noto Serif JP',
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: c.onSurface,
                    ),
                  ),
                ),
              ),
              if (trend != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isPositive)
                      Icon(Icons.trending_up, size: 14, color: trendColor),
                    const SizedBox(width: 4),
                    Text(
                      trend!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
