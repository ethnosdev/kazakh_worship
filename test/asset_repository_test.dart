import 'package:flutter_test/flutter_test.dart';
import 'package:kazakh_worship/services/data_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetDataRepository tests', () {
    late DataRepository repo;

    setUp(() {
      repo = AssetDataRepository();
    });

    test('Loads all 142 songs from assets', () async {
      final songs = await repo.getSongs();
      expect(songs.length, 142);
      expect(songs.first.number, 1);
      expect(songs.first.title, 'Кел, кел бізге Имануил');
      expect(songs.first.chords.contains('[A]'), true);
      expect(songs.first.lyrics.isNotEmpty, true);
      expect(songs.last.number, 142);
      expect(songs.last.title, 'Тандаа талархъя');
    });

    test('Loads Song #133 baptism song correctly', () async {
      final song = await repo.getSongByNumber(133);
      expect(song, isNotNull);
      expect(song!.title, 'Құдайдың атымен шомылдым');
      expect(song.chords.contains('[Cm]'), true);
    });

    test('Loads all 6 prayers from assets', () async {
      final prayers = await repo.getPrayers();
      expect(prayers.length, 6);
      expect(prayers.first.id, 'apostles_creed');
      expect(prayers.first.titleKk, 'Сенім белгісі');
      expect(prayers.first.contentMn, isNotNull);
    });

    test('Loads all 3 guitar guides from assets', () async {
      final guides = await repo.getGuitarGuides();
      expect(guides.length, 3);
      expect(guides.first.id, 'tuning');
      expect(guides.first.title, 'Гитарды қалай көктеу');
    });

    test('Loads all 19 categories from assets', () async {
      final categories = await repo.getCategories();
      expect(categories.length, 19);
      expect(categories.first.name, 'Мәсіхтің туылуы');
    });
  });
}
