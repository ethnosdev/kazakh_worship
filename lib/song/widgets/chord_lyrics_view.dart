import 'package:material_ui/material_ui.dart';
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

    final textStyle = TextStyle(
      fontSize: fontSize,
      height: 1.5,
      color: theme.textTheme.bodyLarge?.color,
    );
    final chordStyle = TextStyle(
      fontSize: (fontSize * 0.85).clamp(11.0, 26.0),
      fontWeight: FontWeight.bold,
      color: chordColor,
    );
    final chorusStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: theme.colorScheme.secondary,
    );
    final commentStyle = textStyle.copyWith(
      fontStyle: FontStyle.italic,
      fontSize: (fontSize - 2).clamp(10.0, 38.0),
    );

    final text = showChords ? song.chords : song.lyrics;
    final document = ChordProcessor(context).processText(
      text: text,
      lyricsStyle: textStyle,
      chordStyle: chordStyle,
      chorusStyle: chorusStyle,
      widgetPadding: 40,
      breakingCharacters: const [' ', ',', '.', '。', '、'],
    );

    final lineWidgets = _buildLineWidgets(
      document.chordLyricsLines,
      textStyle: textStyle,
      chordStyle: chordStyle,
      chorusStyle: chorusStyle,
      commentStyle: commentStyle,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 20.0;
        const verticalPadding = 16.0;
        final minWidth = (constraints.maxWidth - horizontalPadding * 2)
            .clamp(0.0, double.infinity);

        return SelectionArea(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showChords && song.meter.isNotEmpty)
                      _buildMeterBadge(theme),
                    ...lineWidgets,
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeterBadge(ThemeData theme) {
    return Container(
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
    );
  }

  List<Widget> _buildLineWidgets(
    List<ChordLyricsLine> lines, {
    required TextStyle textStyle,
    required TextStyle chordStyle,
    required TextStyle chorusStyle,
    required TextStyle commentStyle,
  }) {
    final widgets = <Widget>[];
    var isChorus = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.isStartOfChorus()) isChorus = true;
      if (line.isEndOfChorus()) isChorus = false;

      final lineStyle = isChorus
          ? chorusStyle
          : line.isComment()
              ? commentStyle
              : textStyle;

      if (i > 0) {
        widgets.add(const SizedBox(height: 8.0));
      }

      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showChords && line.chords.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: line.chords
                    .map(
                      (chord) => Padding(
                        padding: EdgeInsets.only(left: chord.leadingSpace),
                        child: Text.rich(
                          TextSpan(
                            text: chord.chordText,
                            style: chordStyle,
                          ),
                          textScaler: TextScaler.noScaling,
                        ),
                      ),
                    )
                    .toList(),
              ),
            Text.rich(
              TextSpan(text: line.lyrics, style: lineStyle),
              textScaler: TextScaler.noScaling,
            ),
          ],
        ),
      );
    }

    return widgets;
  }
}
