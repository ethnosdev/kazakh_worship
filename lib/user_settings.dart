import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  static const String isDarkKey = 'isDark';
  static const String themeModeKey = 'themeMode';
  static const String fontSizeKey = 'fontSize';
  static const String showChordsKey = 'showChords';
  static const String sortByNumberKey = 'sortByNumber';

  final fontSizeNotifier = ValueNotifier<double>(18.0);
  final showChordsNotifier = ValueNotifier<bool>(false);

  double get fontSize => fontSizeNotifier.value;
  bool get showChords => showChordsNotifier.value;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    fontSizeNotifier.value = prefs.getDouble(fontSizeKey) ?? 18.0;
    showChordsNotifier.value = prefs.getBool(showChordsKey) ?? false;
  }

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(themeModeKey);
    if (modeString != null) {
      if (modeString == 'light') return ThemeMode.light;
      if (modeString == 'dark') return ThemeMode.dark;
      return ThemeMode.system;
    }
    final isDark = prefs.getBool(isDarkKey);
    if (isDark == null) return ThemeMode.system;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        await prefs.setBool(isDarkKey, false);
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        await prefs.setBool(isDarkKey, true);
        break;
      case ThemeMode.system:
        modeString = 'system';
        await prefs.remove(isDarkKey);
        break;
    }
    await prefs.setString(themeModeKey, modeString);
  }

  Future<bool> getIsDark() async {
    final mode = await getThemeMode();
    return mode == ThemeMode.dark;
  }

  Future<void> setIsDark(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getDouble(fontSizeKey) ?? 18.0;
    fontSizeNotifier.value = size;
    return size;
  }

  void setFontSizePreview(double fontSize) {
    fontSizeNotifier.value = fontSize;
  }

  Future<void> setFontSize(double fontSize) async {
    fontSizeNotifier.value = fontSize;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(fontSizeKey, fontSize);
  }

  Future<bool> getShowChords() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getBool(showChordsKey) ?? false;
    showChordsNotifier.value = val;
    return val;
  }

  Future<void> setShowChords(bool showChords) async {
    showChordsNotifier.value = showChords;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(showChordsKey, showChords);
  }

  Future<bool> getSortByNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(sortByNumberKey) ?? true;
  }

  Future<void> setSortByNumber(bool sortByNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(sortByNumberKey, sortByNumber);
  }
}
