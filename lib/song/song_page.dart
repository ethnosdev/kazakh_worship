import 'package:flutter/material.dart';
import 'package:kazakh_worship/models/song.dart';
import 'package:kazakh_worship/song/song_page_manager.dart';

class SongPage extends StatefulWidget {
  const SongPage({
    super.key,
    required this.song,
  });

  final Song song;

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  final manager = SongPageManager();

  @override
  void initState() {
    super.initState();
    manager.init(widget.song.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.song.title),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: manager.loadingNotifier,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const LinearProgressIndicator();
          } else {
            return LyricsWidget(manager: manager);
          }
        },
      ),
    );
  }
}

class LyricsWidget extends StatelessWidget {
  const LyricsWidget({
    super.key,
    required this.manager,
  });

  final SongPageManager manager;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(manager.lyrics),
      ),
    );
  }
}
