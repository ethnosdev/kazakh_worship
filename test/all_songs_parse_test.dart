import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_chord/flutter_chord.dart';
import 'package:kazakh_worship/data/songs_data.dart';

void main() {
  testWidgets('Every song in songList parses cleanly with ChordProcessor', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final processor = ChordProcessor(context);
            for (final song in songList) {
              final doc = processor.processText(
                text: song.chords,
                lyricsStyle: const TextStyle(fontSize: 18),
                chordStyle: const TextStyle(fontSize: 15),
                chorusStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                breakingCharacters: const [' ', ',', '.', '。', '、'],
              );
              expect(doc.chordLyricsLines.isNotEmpty, true, reason: 'Song #${song.number} has empty parsed lines');
            }
            return const SizedBox();
          },
        ),
      ),
    );
  });
}
