import 'package:flutter/material.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:kazakh_worship/user_settings.dart';

class ThemeManager {
  final themeListener = ValueNotifier<ThemeData>(_lightTheme);
  final userSettings = getIt<UserSettings>();
  bool _isDark = false;

  Future<void> init() async {
    _isDark = await userSettings.getIsDark();
    if (_isDark) {
      themeListener.value = _darkTheme;
    } else {
      themeListener.value = _lightTheme;
    }
  }

  bool get isDark => _isDark;

  void toggleTheme() async {
    _isDark = !_isDark;
    if (_isDark) {
      themeListener.value = _darkTheme;
    } else {
      themeListener.value = _lightTheme;
    }
    await userSettings.setIsDark(_isDark);
  }
}

final _lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorSchemeSeed: const Color(0xFF1E3A8A), // Deep royal blue
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

final _darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorSchemeSeed: const Color(0xFF3B82F6),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
