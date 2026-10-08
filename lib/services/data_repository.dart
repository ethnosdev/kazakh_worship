import 'package:kazakh_worship/data/categories_data.dart';
import 'package:kazakh_worship/data/guitar_data.dart';
import 'package:kazakh_worship/data/prayers_data.dart';
import 'package:kazakh_worship/data/songs_data.dart';
import 'package:kazakh_worship/models/guitar_guide.dart';
import 'package:kazakh_worship/models/prayer.dart';
import 'package:kazakh_worship/models/song.dart';

abstract class DataRepository {
  Future<List<Song>> getSongs();
  Future<Song> getSong({required String id});
  Future<Song?> getSongByNumber(int number);
  Future<List<PrayerItem>> getPrayers();
  Future<List<GuitarGuideItem>> getGuitarGuides();
  Future<List<SongCategory>> getCategories();
}

class FakeData implements DataRepository {
  @override
  Future<List<Song>> getSongs() async {
    return songList;
  }

  @override
  Future<Song> getSong({required String id}) async {
    return songList.firstWhere((song) => song.id == id);
  }

  @override
  Future<Song?> getSongByNumber(int number) async {
    final results = songList.where((song) => song.number == number);
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<List<PrayerItem>> getPrayers() async {
    return prayerList;
  }

  @override
  Future<List<GuitarGuideItem>> getGuitarGuides() async {
    return guitarGuideList;
  }

  @override
  Future<List<SongCategory>> getCategories() async {
    return categoryList;
  }
}
