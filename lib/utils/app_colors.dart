import 'package:flutter/material.dart';

/// Free2B's semantic dark-mode palette.
///
/// New UI should use the semantic names at the top of this class. The aliases
/// at the bottom keep older screens visually stable while they are migrated.
abstract final class AppColors {
  static const Color background = Color(0xFF0F0F10);
  static const Color surface = Color(0xFF1B1B1B);
  static const Color surfaceElevated = Color(0xFF252525);
  static const Color primary = Color(0xFFD4AF37);
  static const Color secondary = Color(0xFF5B23E5);
  static const Color accent = Color(0xFFFF58F3);
  static const Color textPrimary = Color(0xFFF9F9F9);
  static const Color textSecondary = Color(0xFFAAAAAC);
  static const Color border = Color(0xFF323233);
  static const Color divider = Color(0xFF2A2A2B);
  static const Color disabled = Color(0xFF4E4E4E);
  static const Color success = Color(0xFF0F8644);
  static const Color warning = Color(0xFFF6C453);
  static const Color error = Color(0xFFFF5A5F);

  // Map surfaces and states deliberately share the application palette.
  static const Color mapBackground = Color(0xFF070A13);
  static const Color mapSurface = Color(0xF20B0F18);
  static const Color mapBorder = Color(0x29FFFFFF);
  static const Color mapPrimary = secondary;
  static const Color mapAccent = accent;
  static const Color mapLocation = Color(0xFF2D9BFF);
  static const Color mapWater = Color(0xFF06345D);

  // Compatibility aliases for the original design system.
  static const Color greenColor = Color(0xFF0D6D3D);
  static const Color greenLightColor = success;
  static const Color textColor = textPrimary;
  static const Color unselectedIconColor = Color(0xFF8A8A8A);
  static const Color textLightColor = textSecondary;
  static const Color redColor = error;
  static const Color dividerColor = divider;
  static const Color appThemeColor = secondary;
  static const Color backgroundColor = background;
  static const Color linearColor = border;
  static const Color backgroundLightColor = surface;
  static const Color disableButtonColor = disabled;
  static const Color yellowButtonColor = primary;
  static const Color bottomSheetColor = surfaceElevated;
  static const Color calenderTextColor = textPrimary;
  static const Color blackColor = background;
}
