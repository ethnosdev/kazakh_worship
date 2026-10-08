import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_chord/flutter_chord.dart';
import 'package:kazakh_worship/data/songs_data.dart';

void main() {
  testWidgets('LyricsRenderer renders Song #1 with chords and without chords', (tester) async {
    final song1 = songList.firstWhere((s) => s.number == 1);

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
    final song1 = songList.firstWhere((s) => s.number == 1);

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
}
