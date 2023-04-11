import 'package:kazakh_worship/models/song.dart';
import 'package:kazakh_worship/services/songs.dart';

abstract class DataRepository {
  Future<List<Song>> getSongs();

  Future<Song> getSong({required String id});
}

class FakeData implements DataRepository {
  @override
  Future<List<Song>> getSongs() async {
    return songList;
  }

  @override
  Future<Song> getSong({required String id}) async {
    return songList.where((song) => song.id == id).first;
  }
}
