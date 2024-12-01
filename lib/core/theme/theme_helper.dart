import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeHelper on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
  Color get textColor => isDark ? Colors.white : Colors.black87;
  Color get surfaceColor => isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get accentTextColor => isDark ? Colors.white : Colors.white;
}
