import 'package:flutter/material.dart';
import 'package:flutter_chord/flutter_chord.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chordColor = theme.brightness == Brightness.dark
        ? const Color(0xFFFBBF24) // warm amber in dark mode
        : const Color(0xFFB45309); // deep amber in light mode

    final text = showChords ? song.chords : song.lyrics;

    return SelectionArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: LyricsRenderer(
          lyrics: text,
          textStyle: TextStyle(
            fontSize: fontSize,
            height: 1.5,
            color: theme.textTheme.bodyLarge?.color,
          ),
          chordStyle: TextStyle(
            fontSize: (fontSize * 0.85).clamp(11.0, 26.0),
            fontWeight: FontWeight.bold,
            color: chordColor,
          ),
          chorusStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            height: 1.5,
            color: theme.colorScheme.secondary,
          ),
          showChord: showChords,
          onTapChord: (chord) {},
          horizontalAlignment: CrossAxisAlignment.start,
          widgetPadding: 40,
          lineHeight: 8.0,
          leadingWidget: (showChords && song.meter.isNotEmpty)
              ? Container(
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
                )
              : null,
          trailingWidget: const SizedBox(height: 32),
        ),
      ),
    );
  }
}
