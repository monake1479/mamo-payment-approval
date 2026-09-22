import 'package:flutter/material.dart';

@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.infoContainer,
    required this.onInfoContainer,
    required this.pendingContainer,
    required this.onPendingContainer,
  });

  final Color infoContainer;
  final Color onInfoContainer;
  final Color pendingContainer;
  final Color onPendingContainer;

  @override
  AppStatusColors copyWith({
    Color? infoContainer,
    Color? onInfoContainer,
    Color? pendingContainer,
    Color? onPendingContainer,
  }) {
    return AppStatusColors(
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      pendingContainer: pendingContainer ?? this.pendingContainer,
      onPendingContainer: onPendingContainer ?? this.onPendingContainer,
    );
  }

  @override
  AppStatusColors lerp(AppStatusColors? other, double t) {
    if (other == null) {
      return this;
    }
    return AppStatusColors(
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      pendingContainer: Color.lerp(
        pendingContainer,
        other.pendingContainer,
        t,
      )!,
      onPendingContainer: Color.lerp(
        onPendingContainer,
        other.onPendingContainer,
        t,
      )!,
    );
  }
}
