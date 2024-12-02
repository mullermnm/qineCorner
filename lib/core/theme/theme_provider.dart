import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  late SharedPreferences _prefs;

  ThemeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  ThemeMode get themeMode => state;
  bool get isDarkMode => state == ThemeMode.dark;

  ThemeData get theme => isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  // Initialize theme based on device theme
  Future<void> initializeTheme(bool isDark) async {
    _prefs = await SharedPreferences.getInstance();
    if (!_prefs.containsKey(_themeKey)) {
      final initialTheme = isDark ? ThemeMode.dark : ThemeMode.light;
      await setThemeMode(initialTheme);
    }
  }

  // Initialize the theme provider with device's theme
  Future<void> _loadThemeMode() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final String? storedTheme = _prefs.getString(_themeKey);
      
      if (storedTheme != null) {
        state = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == storedTheme,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  // Update theme mode and save to preferences
  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;

    state = mode;

    try {
      await _prefs.setString(_themeKey, mode.toString());
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  // Toggle between light and dark theme
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
