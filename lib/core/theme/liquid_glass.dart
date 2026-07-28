import 'package:flutter/material.dart';

class LiquidGlassConfig {
  final double blurSigma;
  final double backgroundOpacity;
  final double refractionOffset;
  final double highlightOpacity;
  final double borderGlowOpacity;
  final double borderRadius;

  const LiquidGlassConfig({
    this.blurSigma = 20,
    this.backgroundOpacity = 0.65,
    this.refractionOffset = 0.5,
    this.highlightOpacity = 0.08,
    this.borderGlowOpacity = 0.12,
    this.borderRadius = 16,
  });

  static const frosted = LiquidGlassConfig(
    blurSigma: 20,
    backgroundOpacity: 0.65,
    refractionOffset: 0.5,
    highlightOpacity: 0.08,
    borderGlowOpacity: 0.12,
    borderRadius: 16,
  );

  static const heavy = LiquidGlassConfig(
    blurSigma: 30,
    backgroundOpacity: 0.8,
    refractionOffset: 0.3,
    highlightOpacity: 0.05,
    borderGlowOpacity: 0.08,
    borderRadius: 12,
  );

  static const light = LiquidGlassConfig(
    blurSigma: 12,
    backgroundOpacity: 0.45,
    refractionOffset: 0.8,
    highlightOpacity: 0.12,
    borderGlowOpacity: 0.15,
    borderRadius: 20,
  );

  static const bar = LiquidGlassConfig(
    blurSigma: 30,
    backgroundOpacity: 0.78,
    refractionOffset: 0.0,
    highlightOpacity: 0.06,
    borderGlowOpacity: 0.1,
    borderRadius: 0,
  );
}

bool isIOS(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS;
}
