import 'package:flutter_test/flutter_test.dart';
import 'package:kazakh_worship/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserSettings Tests', () {
    test('Default values match requirements', () async {
      final settings = UserSettings();

      // Font size defaults to 18.0
      expect(await settings.getFontSize(), 18.0);

      // Chords default to OFF (false)
      expect(await settings.getShowChords(), isFalse);

      // Dark mode defaults to false
      expect(await settings.getIsDark(), isFalse);

      // Sort by number defaults to true
      expect(await settings.getSortByNumber(), isTrue);
    });

    test('Updating font size persists correctly', () async {
      final settings = UserSettings();
      await settings.setFontSize(24.0);
      expect(await settings.getFontSize(), 24.0);
    });

    test('Updating chord visibility persists correctly', () async {
      final settings = UserSettings();
      await settings.setShowChords(true);
      expect(await settings.getShowChords(), isTrue);
      await settings.setShowChords(false);
      expect(await settings.getShowChords(), isFalse);
    });

    test('Updating sort by number persists correctly', () async {
      final settings = UserSettings();
      await settings.setSortByNumber(false);
      expect(await settings.getSortByNumber(), isFalse);
    });

    test('Updating dark mode persists correctly', () async {
      final settings = UserSettings();
      await settings.setIsDark(true);
      expect(await settings.getIsDark(), isTrue);
    });
  });
}
