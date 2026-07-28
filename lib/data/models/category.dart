import 'package:flutter/material.dart';

class SignCategory {
  const SignCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.gradientIndex,
    this.heroImage,
    this.secondaryImage,
  });

  final String id;
  final String name;
  final String emoji;
  final String description;
  final int gradientIndex;

  /// Asset path for the category hero / kid illustration,
  /// e.g. `assets/images/kid_bg.webp`.
  final String? heroImage;

  final String? secondaryImage;

  /// Resolved hero asset — falls back to the shared kid background.
  String get heroImageAsset =>
      (heroImage != null && heroImage!.isNotEmpty)
          ? heroImage!
          : 'assets/images/kid_bg.webp';

  List<Color> gradientColors(BuildContext context) {
    // Resolved in widget layer via AppColors
    return [];
  }
}
