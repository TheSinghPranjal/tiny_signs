import 'package:flutter/material.dart';

abstract final class AppColors {
  // Light mode — soft pastels
  static const skyTop = Color(0xFFB8E0FF);
  static const skyBottom = Color(0xFFE8F4FD);
  static const peach = Color(0xFFFFD6BA);
  static const lavender = Color(0xFFE8D5F2);
  static const mint = Color(0xFFC8F0D8);
  static const butter = Color(0xFFFFF3C4);
  static const coral = Color(0xFFFFB4A2);
  static const rose = Color(0xFFF8BBD9);
  static const periwinkle = Color(0xFFC5CAE9);

  static const textPrimary = Color(0xFF3D3D5C);
  static const textSecondary = Color(0xFF6B6B8A);
  static const starGold = Color(0xFFFFD54F);
  static const successGreen = Color(0xFF81C784);

  // Dark mode — soft nighttime
  static const nightTop = Color(0xFF1A1A2E);
  static const nightBottom = Color(0xFF2D2D44);
  static const nightCard = Color(0xFF3D3D5C);
  static const nightAccent = Color(0xFF7B8CDE);
  static const nightText = Color(0xFFE8E8F0);

  static const categoryGradients = <List<Color>>[
    [Color(0xFFFFE0EC), Color(0xFFFFB4C8)],
    [Color(0xFFD4EDFF), Color(0xFFA8D8FF)],
    [Color(0xFFFFF0D4), Color(0xFFFFD699)],
    [Color(0xFFE8D5F2), Color(0xFFD4B8E8)],
    [Color(0xFFC8F0D8), Color(0xFF98D4B0)],
    [Color(0xFFFFE8D6), Color(0xFFFFCBA4)],
    [Color(0xFFDCE8FF), Color(0xFFB8CCFF)],
    [Color(0xFFFFD6E8), Color(0xFFFFB8D0)],
    [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
    [Color(0xFFFFF9C4), Color(0xFFFFF176)],
    [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
    [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
  ];
}
