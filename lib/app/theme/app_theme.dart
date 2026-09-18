import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_status_colors.dart';

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
    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(controlRadius),
      borderSide: BorderSide(color: colors.outline),
    );
    final AppStatusColors statusColors = AppStatusColors(
      infoContainer: isDark ? const Color(0xFF17365D) : const Color(0xFFD6E4FF),
      onInfoContainer: isDark
          ? const Color(0xFFD6E4FF)
          : const Color(0xFF001B3E),
      pendingContainer: isDark
          ? const Color(0xFF5B4300)
          : const Color(0xFFFFDEA1),
      onPendingContainer: isDark
          ? const Color(0xFFFFDEA1)
          : const Color(0xFF271900),
    );
    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[statusColors],
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
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: compactPadding,
          vertical: compactPadding,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colors.surfaceContainerLow,
        selectedColor: colors.primaryContainer,
        disabledColor: colors.surfaceContainerHighest,
        side: BorderSide(color: colors.outlineVariant),
        shape: controlShape,
        padding: const EdgeInsets.symmetric(horizontal: smallGap),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceContainerLow,
        indicatorColor: colors.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.surfaceContainerLow,
        indicatorColor: colors.primaryContainer,
        selectedIconTheme: IconThemeData(color: colors.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: colors.onSurfaceVariant),
        selectedLabelTextStyle: base.textTheme.labelMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: base.textTheme.labelMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.fixed,
        backgroundColor: colors.inverseSurface,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: colors.onInverseSurface,
        ),
        actionTextColor: colors.inversePrimary,
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
