import 'package:flutter/material.dart';
import 'package:kazakh_worship/models/song.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:kazakh_worship/services/data_repository.dart';

class HomePageManager {
  final songNotifier = ValueNotifier<List<Song>>([]);
  final dataRepo = getIt<DataRepository>();
  late final List<Song> _songs;

  Future<void> init() async {
    _songs = await dataRepo.getSongs();
    songNotifier.value = _songs;
  }

  void search(String word) {
    final results = _songs
        .where((song) => song.title.toLowerCase().contains(word.toLowerCase()))
        .toList();
    songNotifier.value = results;
  }
}
