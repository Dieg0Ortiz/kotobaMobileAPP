import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';

/// Shimmer loading skeleton para diferentes tipos de contenido.
enum KotobaLoadingType { card, text, profile, fullScreen }

class KotobaLoading extends StatelessWidget {
  final KotobaLoadingType type;

  const KotobaLoading({this.type = KotobaLoadingType.fullScreen, super.key});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case KotobaLoadingType.fullScreen:
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        );
      case KotobaLoadingType.card:
        return _shimmerCard();
      case KotobaLoadingType.text:
        return _shimmerText();
      case KotobaLoadingType.profile:
        return _shimmerProfile();
    }
  }

  Widget _shimmerCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLow,
      highlightColor: AppColors.surfaceHigh,
      child: Container(
        width: 140,
        height: 210,
        decoration: BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _shimmerText() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLow,
      highlightColor: AppColors.surfaceHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerProfile() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLow,
      highlightColor: AppColors.surfaceHigh,
      child: Column(
        children: [
          const CircleAvatar(radius: 48, backgroundColor: AppColors.surfaceLow),
          const SizedBox(height: 16),
          Container(
            height: 20,
            width: 150,
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
