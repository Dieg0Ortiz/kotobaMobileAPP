import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/kotoba_colors.dart';

/// Shimmer loading skeleton para diferentes tipos de contenido.
enum KotobaLoadingType { card, text, profile, fullScreen }

class KotobaLoading extends StatelessWidget {
  final KotobaLoadingType type;

  const KotobaLoading({this.type = KotobaLoadingType.fullScreen, super.key});

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    switch (type) {
      case KotobaLoadingType.fullScreen:
        return Center(
          child: CircularProgressIndicator(
            color: c.primary,
            strokeWidth: 2,
          ),
        );
      case KotobaLoadingType.card:
        return _shimmerCard(c);
      case KotobaLoadingType.text:
        return _shimmerText(c);
      case KotobaLoadingType.profile:
        return _shimmerProfile(c);
    }
  }

  Widget _shimmerCard(KotobaColors c) {
    return Shimmer.fromColors(
      baseColor: c.surfaceLow,
      highlightColor: c.surfaceHigh,
      child: Container(
        width: 140,
        height: 210,
        decoration: BoxDecoration(
          color: c.surfaceLow,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _shimmerText(KotobaColors c) {
    return Shimmer.fromColors(
      baseColor: c.surfaceLow,
      highlightColor: c.surfaceHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: c.surfaceLow,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: 200,
            decoration: BoxDecoration(
              color: c.surfaceLow,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerProfile(KotobaColors c) {
    return Shimmer.fromColors(
      baseColor: c.surfaceLow,
      highlightColor: c.surfaceHigh,
      child: Column(
        children: [
          CircleAvatar(radius: 48, backgroundColor: c.surfaceLow),
          const SizedBox(height: 16),
          Container(
            height: 20,
            width: 150,
            decoration: BoxDecoration(
              color: c.surfaceLow,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
