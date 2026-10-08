import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  static const String isDarkKey = 'isDark';
  static const String fontSizeKey = 'fontSize';
  static const String showChordsKey = 'showChords';
  static const String sortByNumberKey = 'sortByNumber';

  Future<bool> getIsDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isDarkKey) ?? false;
  }

  Future<void> setIsDark(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isDarkKey, isDark);
  }

  Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(fontSizeKey) ?? 18.0;
  }

  Future<void> setFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(fontSizeKey, fontSize);
  }

  Future<bool> getShowChords() async {
    final prefs = await SharedPreferences.getInstance();
    // Guitar chords are OFF by default
    return prefs.getBool(showChordsKey) ?? false;
  }

  Future<void> setShowChords(bool showChords) async {
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
