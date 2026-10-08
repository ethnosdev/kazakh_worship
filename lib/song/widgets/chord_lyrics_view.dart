import 'package:flutter/material.dart';
import 'package:kazakh_worship/models/song.dart';

class ChordLyricsView extends StatelessWidget {
  final Song song;
  final double fontSize;
  final bool showChords;

  const ChordLyricsView({
    super.key,
    required this.song,
    required this.fontSize,
    required this.showChords,
  });

  bool _isChordLine(String line) {
    final l = line.trim();
    if (l.isEmpty) return false;
    if (RegExp(r'^(?:\d+\.|\d+\)|\/|\/p|Қ-сы:|ДХ:)').hasMatch(l)) {
      return false;
    }
    final tokens = l.split(RegExp(r'\s+'));
    if (tokens.isEmpty) return false;
    int chordCount = 0;
    for (final tok in tokens) {
      final c = tok.replaceAll(RegExp(r'[()/-:,0-9pPрР]'), '');
      if (c.isEmpty) {
        chordCount++;
        continue;
      }
      if (RegExp(r'^[A-G][b#]?(?:m|maj|min|sus|dim|aug|add)?[0-9]?(?:/[A-G][b#]?)?$').hasMatch(c)) {
        chordCount++;
      } else if (['- ', '-', '/', '2p', '3p', '2р', '3р', '8/', '6/', '4/', '4/Б', '2/', '3/'].contains(c)) {
        chordCount++;
      }
    }
    return (chordCount / tokens.length) >= 0.65;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chordColor = theme.brightness == Brightness.dark
        ? const Color(0xFFFBBF24) // warm amber in dark mode
        : const Color(0xFFB45309); // deep amber in light mode

    final text = showChords ? song.chords : song.lyrics;
    final lines = text.split('\n');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showChords && song.meter.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.music_note,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ырғақ: ${song.meter}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SelectableText.rich(
            TextSpan(
              children: lines.map((line) {
                final isChord = showChords && _isChordLine(line);
                final isChorus = line.trim().startsWith('Қ-сы:') || line.trim().startsWith('ДХ:');
                final isVerseMarker = RegExp(r'^\d+\.').hasMatch(line.trim());

                if (isChord) {
                  return TextSpan(
                    text: '$line\n',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: (fontSize * 0.9).clamp(12.0, 28.0),
                      color: chordColor,
                      letterSpacing: 0.5,
                      height: 1.4,
                    ),
                  );
                } else if (isChorus) {
                  return TextSpan(
                    text: '$line\n',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                      color: theme.colorScheme.secondary,
                      height: 1.5,
                    ),
                  );
                } else if (isVerseMarker) {
                  return TextSpan(
                    text: '$line\n',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                      color: theme.colorScheme.primary,
                      height: 1.5,
                    ),
                  );
                } else {
                  return TextSpan(
                    text: '$line\n',
                    style: TextStyle(
                      fontSize: fontSize,
                      height: 1.5,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  );
                }
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
