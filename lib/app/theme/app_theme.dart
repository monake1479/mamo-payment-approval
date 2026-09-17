import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppTheme {
  static const double compactPadding = 16;
  static const double pagePadding = 24;
  static const double contentWidth = 520;
  static const double expandedContentWidth = 1040;
  static const double expandedBreakpoint = 720;
  static const double sectionGap = 24;
  static const double itemGap = 12;
  static const double smallGap = 8;
  static const double cardRadius = 20;
  static const double controlRadius = 14;
  static const double minimumTouchTarget = 48;
  static const double compactNavigationHeight = 80;

  static ThemeData get light => _create(Brightness.light);
  static ThemeData get dark => _create(Brightness.dark);

  static SystemUiOverlayStyle systemUiOverlayStyle(ColorScheme colors) {
    final Brightness backgroundBrightness =
        ThemeData.estimateBrightnessForColor(colors.surface);
    return SystemUiOverlayStyle(
      statusBarColor: colors.surface,
      statusBarBrightness: backgroundBrightness,
      statusBarIconBrightness: backgroundBrightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    );
  }

  static ThemeData _create(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme colors =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF6938EF),
          brightness: brightness,
        ).copyWith(
          primary: isDark ? const Color(0xFFC9B6FF) : const Color(0xFF6130D8),
          onPrimary: isDark ? const Color(0xFF2D116C) : Colors.white,
          surface: isDark ? const Color(0xFF17151D) : const Color(0xFFF7F7FA),
          surfaceContainerLow: isDark ? const Color(0xFF211E29) : Colors.white,
          onSurface: isDark ? const Color(0xFFF2EFF8) : const Color(0xFF211C2D),
          onSurfaceVariant: isDark
              ? const Color(0xFFC2BBCF)
              : const Color(0xFF625B70),
        );
    final ThemeData base = ThemeData(
      colorScheme: colors,
      useMaterial3: true,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );
    final RoundedRectangleBorder controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(controlRadius),
    );
    return base.copyWith(
      scaffoldBackgroundColor: colors.surface,
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: systemUiOverlayStyle(colors),
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: colors.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(minimumTouchTarget, minimumTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: pagePadding,
            vertical: itemGap,
          ),
          shape: controlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(minimumTouchTarget, minimumTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: pagePadding,
            vertical: itemGap,
          ),
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(minimumTouchTarget, minimumTouchTarget),
          shape: controlShape,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceContainerLow,
        indicatorColor: colors.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadius)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: controlShape,
      ),
    );
  }
}
