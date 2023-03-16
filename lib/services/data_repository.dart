import 'package:kazakh_worship/models/song.dart';

abstract class DataRepository {
  Future<List<Song>> getSongs();
}

class FakeData implements DataRepository {
  @override
  Future<List<Song>> getSongs() async {
    return [
      Song('20202', 'Адамдар, ойланындар', null),
      Song('21212', 'Айқыш ағашта қиналдың', null),
      Song('22222', 'Алғыс Саған, жалғыз Саған', null),
    ];
  }
}
