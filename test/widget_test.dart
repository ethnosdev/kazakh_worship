import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazakh_worship/main.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    setupServiceLocater();
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('Worship app smoke test - Navigation and Song viewing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify main app bar title and navigation destinations
    expect(find.text('Құдайға мадақтайық'), findsOneWidget);
    expect(find.text('Әндер'), findsOneWidget);
    expect(find.text('Дұғалар'), findsOneWidget);
    expect(find.text('Гитара'), findsOneWidget);

    // Verify first song is displayed with its number
    expect(find.text('Кел, кел бізге Имануил'), findsOneWidget);
    expect(find.text('1'), findsWidgets);

    // Tap on the first song to open SongPage
    await tester.tap(find.text('Кел, кел бізге Имануил').first);
    await tester.pumpAndSettle();

    // Verify SongPage header and song number
    expect(find.text('#1 Кел, кел бізге Имануил'), findsOneWidget);

    // By default, chords are OFF
    expect(find.byTooltip('Аккордтарды көрсету'), findsOneWidget);

    // Toggle chords ON
    await tester.tap(find.byTooltip('Аккордтарды көрсету'));
    await tester.pumpAndSettle();

    // Now chords button says 'Аккордтарды жасыру'
    expect(find.byTooltip('Аккордтарды жасыру'), findsOneWidget);

    // Go back to home
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Switch to Prayers tab
    await tester.tap(find.text('Дұғалар'));
    await tester.pumpAndSettle();

    expect(find.text('Дұғалар мен сенім'), findsOneWidget);
    expect(find.text('Сенім белгісі'), findsOneWidget);

    // Switch to Guitar tab
    await tester.tap(find.text('Гитара'));
    await tester.pumpAndSettle();

    expect(find.text('Гитара үйрену'), findsWidgets);
    expect(find.text('Гитарды қалай көктеу'), findsOneWidget);
  });
}
