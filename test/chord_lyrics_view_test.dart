import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_chord/flutter_chord.dart';
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

  testWidgets('LyricsRenderer renders Song #1 with chords and without chords', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: LyricsRenderer(
              lyrics: song1.chords,
              textStyle: const TextStyle(fontSize: 18, color: Colors.black),
              chordStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber),
              showChord: true,
              onTapChord: (_) {},
              horizontalAlignment: CrossAxisAlignment.start,
              widgetPadding: 40,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LyricsRenderer), findsOneWidget);
    // Find text from song 1
    expect(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Имануил')), findsWidgets);
    expect(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText() == 'A'), findsWidgets);
    expect(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText() == 'F#m'), findsWidgets);
  });

  testWidgets('LyricsRenderer renders Song #1 without chords', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: LyricsRenderer(
              lyrics: song1.chords,
              textStyle: const TextStyle(fontSize: 18, color: Colors.black),
              chordStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber),
              showChord: false,
              onTapChord: (_) {},
              horizontalAlignment: CrossAxisAlignment.start,
              widgetPadding: 40,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LyricsRenderer), findsOneWidget);
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
