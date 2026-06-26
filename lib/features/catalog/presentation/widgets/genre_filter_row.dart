import 'package:flutter/material.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/widgets/common/kotoba_chip.dart';

/// Fila horizontal de chips de género para filtrado.
class GenreFilterRow extends StatelessWidget {
  final String selectedGenre;
  final ValueChanged<String> onGenreSelected;

  const GenreFilterRow({
    required this.selectedGenre,
    required this.onGenreSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: MockData.genres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = MockData.genres[index];
          return KotobaChip(
            label: genre,
            isSelected: genre == selectedGenre,
            onTap: () => onGenreSelected(genre),
          );
        },
      ),
    );
  }
}
