import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const double pagePadding = 24;
  static const double contentWidth = 520;
  static const double sectionGap = 24;
  static const double itemGap = 12;

  static ThemeData get light {
    const Color seedColor = Color(0xFF6D5AE6);

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      useMaterial3: true,
    );
  }
}
