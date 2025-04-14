// Theme state
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final ThemeMode themeMode;

  ThemeState({required this.themeMode});

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(ThemeState(themeMode: ThemeMode.system)) {
    _loadTheme();
  }

  static const String _themeKey = 'app_theme';

  // Load theme from shared preferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      emit(ThemeState(themeMode: _getThemeModeFromString(savedTheme)));
    }
  }

  // Set theme and save to shared preferences
  Future<void> setTheme(ThemeMode themeMode) async {
    emit(state.copyWith(themeMode: themeMode));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _getStringFromThemeMode(themeMode));
  }

  // Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newThemeMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    await setTheme(newThemeMode);
  }

  // Use system theme
  Future<void> useSystemTheme() async {
    await setTheme(ThemeMode.system);
  }

  // Helper methods for ThemeMode conversions
  ThemeMode _getThemeModeFromString(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _getStringFromThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }
}