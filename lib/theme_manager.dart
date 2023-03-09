import 'package:flutter/material.dart';

class ThemeManager {
  final themeListener = ValueNotifier<ThemeData>(_lightTheme);
  bool _isDark = false;

  bool get isDark => _isDark;

  void toggleTheme() {
    print('isDark: $_isDark');
    if (_isDark) {
      themeListener.value = _lightTheme;
    } else {
      themeListener.value = _darkTheme;
    }
    _isDark = !_isDark;
  }
}

final _lightTheme = ThemeData(
  brightness: Brightness.light,
);

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
);
