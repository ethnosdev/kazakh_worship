import 'package:flutter/material.dart';
import 'package:kazakh_worship/models/song.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:kazakh_worship/services/data_repository.dart';

class SongPageManager {
  final loadingNotifier = ValueNotifier<bool>(true);
  final dataRepo = getIt<DataRepository>();

  String get lyrics => _song.lyrics ?? '';
  late Song _song;

  Future<void> init(String songId) async {
    loadingNotifier.value = true;
    _song = await dataRepo.getSong(id: songId);
    loadingNotifier.value = false;
  }
}
