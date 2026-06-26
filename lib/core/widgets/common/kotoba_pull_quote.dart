import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Pull quote decorativo con borde izquierdo gold y texto Noto Serif JP italic.
class KotobaPullQuote extends StatelessWidget {
  final String text;

  const KotobaPullQuote({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 16, bottom: 16),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.primaryContainer, width: 3),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Noto Serif JP',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          height: 1.6,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
