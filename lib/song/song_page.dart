import 'package:flutter/material.dart';
import 'package:kazakh_worship/models/song.dart';
import 'package:kazakh_worship/shared/zoom_wrapper.dart';
import 'package:kazakh_worship/song/song_page_manager.dart';
import 'package:kazakh_worship/song/widgets/chord_lyrics_view.dart';
import 'package:kazakh_worship/song/widgets/jump_to_song_dialog.dart';

class SongPage extends StatefulWidget {
  final Song song;

  const SongPage({
    super.key,
    required this.song,
  });

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  final manager = SongPageManager();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initManager();
  }

  Future<void> _initManager() async {
    await manager.init(widget.song.number);
    if (mounted) {
      _pageController.dispose();
      _pageController = PageController(initialPage: manager.currentIndexNotifier.value);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index >= 0 && index < manager.songs.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: manager.loadingNotifier,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text('#${widget.song.number} ${widget.song.title}'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return ValueListenableBuilder<int>(
          valueListenable: manager.currentIndexNotifier,
          builder: (context, currentIndex, child) {
            final currentSong = manager.songs[currentIndex];

            return ValueListenableBuilder<bool>(
              valueListenable: manager.showChordsNotifier,
              builder: (context, showChords, child) {
                return ValueListenableBuilder<double>(
                  valueListenable: manager.fontSizeNotifier,
                  builder: (context, fontSize, child) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${currentSong.number} ${currentSong.title}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (currentSong.category.isNotEmpty || currentSong.meter.isNotEmpty)
                              Text(
                                [
                                  if (currentSong.category.isNotEmpty) currentSong.category,
                                  if (currentSong.meter.isNotEmpty) currentSong.meter,
                                ].join(' • '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(
                              showChords ? Icons.music_note : Icons.music_off,
                              color: showChords
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            tooltip: showChords ? 'Аккордтарды жасыру' : 'Аккордтарды көрсету',
                            onPressed: () => manager.toggleChords(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.tag),
                            tooltip: 'Ән нөміріне өту',
                            onPressed: () {
                              JumpToSongDialog.show(
                                context,
                                maxSongNumber: manager.songs.length,
                                onSongSelected: (number) {
                                  final idx = manager.getIndexForSongNumber(number);
                                  if (idx >= 0) {
                                    _goToPage(idx);
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      body: ZoomWrapper(
                        initialScale: fontSize,
                        minScale: 10.0,
                        maxScale: 40.0,
                        onScaleChanged: (newScale) {
                          manager.setFontSize(newScale);
                        },
                        builder: (context, scale) => PageView.builder(
                          controller: _pageController,
                          itemCount: manager.songs.length,
                          onPageChanged: (index) => manager.onPageChanged(index),
                          itemBuilder: (context, index) {
                            final song = manager.songs[index];
                            return ChordLyricsView(
                              song: song,
                              fontSize: scale,
                              showChords: showChords,
                            );
                          },
                        ),
                      ),
                      bottomNavigationBar: SafeArea(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: currentIndex > 0
                                    ? () => _goToPage(currentIndex - 1)
                                    : null,
                                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                                tooltip: 'Алдыңғы ән',
                              ),
                              GestureDetector(
                                onTap: () {
                                  JumpToSongDialog.show(
                                    context,
                                    maxSongNumber: manager.songs.length,
                                    onSongSelected: (number) {
                                      final idx = manager.getIndexForSongNumber(number);
                                      if (idx >= 0) {
                                        _goToPage(idx);
                                      }
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${currentSong.number} / ${manager.songs.length}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: currentIndex < manager.songs.length - 1
                                    ? () => _goToPage(currentIndex + 1)
                                    : null,
                                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                                tooltip: 'Келесі ән',
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
