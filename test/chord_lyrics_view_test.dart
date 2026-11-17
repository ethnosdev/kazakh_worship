import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazakh_worship/models/song.dart';
import 'package:kazakh_worship/services/data_repository.dart';
import 'package:kazakh_worship/song/widgets/chord_lyrics_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Song song1;
  late Song song2;

  setUpAll(() async {
    final repo = AssetDataRepository();
    song1 = (await repo.getSongByNumber(1))!;
    song2 = (await repo.getSongByNumber(2))!;
  });

  testWidgets('ChordLyricsView renders Song #1 with chords and scrolls horizontally when wide', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChordLyricsView(
            song: song1,
            fontSize: 18.0,
            showChords: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ChordLyricsView), findsOneWidget);
    // Find text from song 1
    expect(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Имануил')), findsWidgets);
    expect(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText() == 'A'), findsWidgets);
    expect(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText() == 'F#m'), findsWidgets);

    final horizontalScrollable = find.byWidgetPredicate(
      (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
    );
    expect(horizontalScrollable, findsOneWidget);
    final scrollableState = tester.state<ScrollableState>(
      find.descendant(of: horizontalScrollable, matching: find.byType(Scrollable)).first,
    );
    expect(scrollableState.position.maxScrollExtent, greaterThan(0.0));
  });

  testWidgets('ChordLyricsView renders Song #1 without chords', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChordLyricsView(
            song: song1,
            fontSize: 18.0,
            showChords: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ChordLyricsView), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Имануил')), findsWidgets);
    // Chords should not be displayed
    expect(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText() == 'A'), findsNothing);
  });

  testWidgets('ChordLyricsView renders vertical space between verses', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChordLyricsView(
            song: song2,
            fontSize: 18.0,
            showChords: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify verse lines exist
    final lineVerse1End = find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Уәдесі жеткен күн'));
    final lineChorusStart = find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Келіңдер, бәрің де келіңдер'));
    expect(lineVerse1End, findsOneWidget);
    expect(lineChorusStart, findsOneWidget);

    final yVerse1End = tester.getBottomLeft(lineVerse1End).dy;
    final yChorusStart = tester.getTopLeft(lineChorusStart).dy;
    // With empty line verse gap, distance is >= 25 px (normal line gap is 8 px)
    expect(yChorusStart - yVerse1End, greaterThan(25.0));
  });
}
