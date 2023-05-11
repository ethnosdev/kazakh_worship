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
    await userSettings.setIsDark(isDark);
  }
}

final _lightTheme = ThemeData(
  brightness: Brightness.light,
);

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
);
