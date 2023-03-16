import 'package:flutter/material.dart';
import 'package:kazakh_worship/models/song.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:kazakh_worship/services/data_repository.dart';

class HomePageManager {
  final songNotifier = ValueNotifier<List<String>>([]);
  final dataRepo = getIt<DataRepository>();
  late final List<Song> _songs;

  Future<void> init() async {
    _songs = await dataRepo.getSongs();
    final titles = _songs.map((song) => song.title).toList();
    songNotifier.value = titles;
    
  }
}
