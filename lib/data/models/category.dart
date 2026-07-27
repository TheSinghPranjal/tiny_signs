import 'package:flutter/material.dart';

class SignCategory {
  const SignCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.gradientIndex,
  });

  final String id;
  final String name;
  final String emoji;
  final String description;
  final int gradientIndex;

  List<Color> gradientColors(BuildContext context) {
    // Resolved in widget layer via AppColors
    return [];
  }
}
