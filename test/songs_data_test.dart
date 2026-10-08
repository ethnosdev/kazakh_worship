import 'package:flutter_test/flutter_test.dart';
import 'package:kazakh_worship/models/song.dart';
import 'package:kazakh_worship/services/data_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Songs Asset Data Integrity Tests', () {
    late List<Song> songList;

    setUpAll(() async {
      final repo = AssetDataRepository();
      songList = await repo.getSongs();
    });

    test('Exactly 142 songs are present', () {
      expect(songList.length, 142);
    });

    test('All songs are sequentially numbered 1 to 142 without gaps', () {
      for (int i = 0; i < songList.length; i++) {
        expect(songList[i].number, i + 1,
            reason: 'Expected song at index $i to have number ${i + 1}');
        expect(songList[i].id, '${i + 1}');
      }
    });

    test('Song #133 is the new baptism song', () {
      final song133 = songList.firstWhere((s) => s.number == 133);
      expect(song133.title, 'Құдайдың атымен шомылдым');
      expect(song133.language, 'kk');
      expect(song133.lyrics.contains('Үш - бірліктің бергені'), isTrue);
      expect(song133.chords.contains('Cm7'), isTrue);
    });

    test('Song #128 is "Құдай мені жаратты"', () {
      final song128 = songList.firstWhere((s) => s.number == 128);
      expect(song128.title, 'Құдай мені жаратты');
      expect(song128.lyrics.contains('Құлақ, көз, мұрын, ауыз!'), isTrue);
    });

    test('Song #12 is "31-ші Забур"', () {
      final song12 = songList.firstWhere((s) => s.number == 12);
      expect(song12.title, '31-ші Забур');
      expect(song12.lyrics.contains('Күнәмді айтқым келмеп еді'), isTrue);
      expect(song12.chords.contains('F#7'), isTrue);
    });

    test('Mongolian companion songs #82 and #115 are present', () {
      final song82 = songList.firstWhere((s) => s.number == 82);
      expect(song82.title, 'Есүс надад хайртайдаа');
      expect(song82.language, 'mn');

      final song115 = songList.firstWhere((s) => s.number == 115);
      expect(song115.title, 'Эзэнээ магтан дуулъя');
      expect(song115.language, 'mn');
    });

    test('Mongolian songs section #134 to #142 are all present', () {
      for (int n = 134; n <= 142; n++) {
        final song = songList.firstWhere((s) => s.number == n);
        expect(song.language, 'mn', reason: 'Song #$n should have language mn');
        expect(song.title.isNotEmpty, isTrue);
        expect(song.lyrics.isNotEmpty, isTrue);
        expect(song.chords.isNotEmpty, isTrue);
      }

      expect(songList.firstWhere((s) => s.number == 134).title, 'Бурхан дэлхийг үнэхээр');
      expect(songList.firstWhere((s) => s.number == 136).title, 'Исаиа 53');
      expect(songList.firstWhere((s) => s.number == 142).title, 'Тандаа талархъя');
    });

    test('All songs have non-empty titles, lyrics, and chords', () {
      for (final song in songList) {
        expect(song.title.trim().isNotEmpty, isTrue,
            reason: 'Song #${song.number} has empty title');
        expect(song.lyrics.trim().isNotEmpty, isTrue,
            reason: 'Song #${song.number} has empty lyrics');
        expect(song.chords.trim().isNotEmpty, isTrue,
            reason: 'Song #${song.number} has empty chords');
      }
    });
  });
}
