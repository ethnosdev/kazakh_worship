import 'package:flutter/material.dart';
import 'package:kazakh_worship/models/song.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:kazakh_worship/services/data_repository.dart';
import 'package:kazakh_worship/user_settings.dart';

class SongPageManager {
  final loadingNotifier = ValueNotifier<bool>(true);
  final showChordsNotifier = ValueNotifier<bool>(false);
  final currentIndexNotifier = ValueNotifier<int>(0);

  final dataRepo = getIt<DataRepository>();
  final userSettings = getIt<UserSettings>();

  ValueNotifier<double> get fontSizeNotifier => userSettings.fontSizeNotifier;

  List<Song> songs = [];

  Song get currentSong => songs.isNotEmpty ? songs[currentIndexNotifier.value] : _emptySong;

  static const _emptySong = Song(
    number: 1,
    id: '1',
    title: '',
    lyrics: '',
    chords: '',
  );

  Future<void> init(int initialSongNumber) async {
    loadingNotifier.value = true;
    songs = List<Song>.from(await dataRepo.getSongs());
    songs.sort((a, b) => a.number.compareTo(b.number));

    final idx = songs.indexWhere((s) => s.number == initialSongNumber);
    currentIndexNotifier.value = idx >= 0 ? idx : 0;

    await userSettings.getFontSize();
    showChordsNotifier.value = await userSettings.getShowChords();
    loadingNotifier.value = false;
  }

  void onPageChanged(int index) {
    if (index >= 0 && index < songs.length) {
      currentIndexNotifier.value = index;
    }
  }

  Future<void> setFontSize(double size) async {
    await userSettings.setFontSize(size);
  }

  Future<void> toggleChords() async {
    final newValue = !showChordsNotifier.value;
    showChordsNotifier.value = newValue;
    await userSettings.setShowChords(newValue);
  }

  int getIndexForSongNumber(int number) {
    return songs.indexWhere((s) => s.number == number);
  }
}
