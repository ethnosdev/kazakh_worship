import 'package:flutter/material.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:kazakh_worship/user_settings.dart';

class ThemeManager {
  final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  final themeListener = ValueNotifier<ThemeData>(_lightTheme);
  final userSettings = getIt<UserSettings>();

  ThemeMode get themeMode => themeModeNotifier.value;
  bool get isDark => themeModeNotifier.value == ThemeMode.dark;

  Future<void> init() async {
    final mode = await userSettings.getThemeMode();
    themeModeNotifier.value = mode;
    _updateThemeListener(mode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    _updateThemeListener(mode);
    await userSettings.setThemeMode(mode);
  }

  void _updateThemeListener(ThemeMode mode) {
    if (mode == ThemeMode.dark) {
      themeListener.value = _darkTheme;
    } else {
      themeListener.value = _lightTheme;
    }
  }

  void toggleTheme() async {
    final newMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  static ThemeData get lightTheme => _lightTheme;
  static ThemeData get darkTheme => _darkTheme;
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
