import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  static const String isDarkKey = 'isDark';
  
  Future<bool> getIsDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isDarkKey) ?? false;
  }

  Future<void> setIsDark(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(isDarkKey, isDark);
  }
}
