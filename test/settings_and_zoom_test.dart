import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:kazakh_worship/settings/settings_page.dart';
import 'package:kazakh_worship/shared/zoom_wrapper.dart';
import 'package:kazakh_worship/theme_manager.dart';
import 'package:kazakh_worship/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    setupServiceLocater();
  });

  tearDown(() {
    getIt.reset();
  });

  group('ZoomWrapper Widget Tests', () {
    testWidgets('renders child at initial scale', (WidgetTester tester) async {
      double scaleUsed = 0.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZoomWrapper(
              initialScale: 18.0,
              onScaleChanged: (scale) {},
              builder: (context, scale) {
                scaleUsed = scale;
                return Text('Sample text', style: TextStyle(fontSize: scale));
              },
            ),
          ),
        ),
      );

      expect(scaleUsed, 18.0);
      expect(find.text('Sample text'), findsOneWidget);
    });

    testWidgets('responds to two-pointer pinch gesture', (WidgetTester tester) async {
      double committedScale = 0.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZoomWrapper(
              initialScale: 20.0,
              minScale: 10.0,
              maxScale: 40.0,
              onScaleChanged: (scale) {
                committedScale = scale;
              },
              builder: (context, scale) {
                return Center(child: Text('Zoom Target', style: TextStyle(fontSize: scale)));
              },
            ),
          ),
        ),
      );

      final center = tester.getCenter(find.text('Zoom Target'));
      final touch1 = await tester.startGesture(center.translate(-20, 0), pointer: 1);
      final touch2 = await tester.startGesture(center.translate(20, 0), pointer: 2);

      // Pinch outward (scale up)
      await touch1.moveBy(const Offset(-40, 0));
      await touch2.moveBy(const Offset(40, 0));
      await tester.pump();

      await touch1.up();
      await touch2.up();
      await tester.pumpAndSettle();

      expect(committedScale, greaterThan(20.0));
    });
  });

  group('SettingsPage and UserSettings Tests', () {
    test('UserSettings ThemeMode persistence', () async {
      final settings = getIt<UserSettings>();
      expect(await settings.getThemeMode(), ThemeMode.system);

      await settings.setThemeMode(ThemeMode.light);
      expect(await settings.getThemeMode(), ThemeMode.light);
      expect(await settings.getIsDark(), isFalse);

      await settings.setThemeMode(ThemeMode.dark);
      expect(await settings.getThemeMode(), ThemeMode.dark);
      expect(await settings.getIsDark(), isTrue);

      await settings.setThemeMode(ThemeMode.system);
      expect(await settings.getThemeMode(), ThemeMode.system);
    });

    testWidgets('SettingsPage allows changing theme and text size', (WidgetTester tester) async {
      final themeManager = getIt<ThemeManager>();
      final userSettings = getIt<UserSettings>();
      await themeManager.init();
      await userSettings.init();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeManager.lightTheme,
          darkTheme: ThemeManager.darkTheme,
          home: const SettingsPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Check title and appearance section
      expect(find.text('Баптаулар / Settings'), findsOneWidget);
      expect(find.text('Көрініс / Appearance'), findsOneWidget);
      expect(find.text('Light-Dark Mode'), findsOneWidget);
      expect(find.text('Text Size'), findsOneWidget);

      // Tap Light-Dark Mode to open SegmentedButton dialog
      await tester.tap(find.text('Light-Dark Mode'));
      await tester.pumpAndSettle();

      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Device'), findsOneWidget);

      // Select Dark mode
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(themeManager.themeMode, ThemeMode.dark);
      expect(await userSettings.getThemeMode(), ThemeMode.dark);

      // Tap Text Size to open slider dialog
      await tester.tap(find.text('Text Size'));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);

      // Change font size
      final slider = find.byType(Slider);
      await tester.tap(slider);
      await tester.pumpAndSettle();

      // Dismiss dialog
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Toggle Show Chords by default switch
      expect(find.text('Show Chords by Default'), findsOneWidget);
      await tester.tap(find.text('Show Chords by Default'));
      await tester.pumpAndSettle();

      expect(userSettings.showChords, isTrue);
      expect(await userSettings.getShowChords(), isTrue);
    });
  });
}
