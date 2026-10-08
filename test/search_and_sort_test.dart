import 'package:flutter_test/flutter_test.dart';
import 'package:kazakh_worship/home/home_page_manager.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    setupServiceLocater();
  });

  tearDown(() {
    getIt.reset();
  });

  group('HomePageManager Search and Filter Tests', () {
    test('Initialization loads all 142 songs in number order by default', () async {
      final manager = HomePageManager();
      await manager.init();

      expect(manager.songNotifier.value.length, 142);
      expect(manager.songNotifier.value.first.number, 1);
      expect(manager.songNotifier.value.last.number, 142);
    });

    test('Searching by exact song number "133" returns song 133 at the top', () async {
      final manager = HomePageManager();
      await manager.init();

      manager.search('133');
      expect(manager.songNotifier.value.isNotEmpty, isTrue);
      expect(manager.songNotifier.value.first.number, 133);
      expect(manager.songNotifier.value.first.title, 'Құдайдың атымен шомылдым');
    });

    test('Searching by title substring returns matching songs', () async {
      final manager = HomePageManager();
      await manager.init();

      manager.search('Имануил');
      final titles = manager.songNotifier.value.map((s) => s.title).toList();
      expect(titles.any((t) => t.contains('Имануил')), isTrue);
    });

    test('Searching by lyrics text returns matching songs', () async {
      final manager = HomePageManager();
      await manager.init();

      manager.search('Үш - бірліктің');
      expect(manager.songNotifier.value.any((s) => s.number == 133), isTrue);
    });

    test('Filtering by language "kk" returns only Kazakh songs', () async {
      final manager = HomePageManager();
      await manager.init();

      manager.setFilter('kk');
      expect(manager.songNotifier.value.every((s) => s.language == 'kk'), isTrue);
      // 142 total - 11 mongolian (82, 115, 134-142) = 131 kazakh songs
      expect(manager.songNotifier.value.length, 131);
    });

    test('Filtering by language "mn" returns all Mongolian songs', () async {
      final manager = HomePageManager();
      await manager.init();

      manager.setFilter('mn');
      expect(manager.songNotifier.value.every((s) => s.language == 'mn'), isTrue);
      expect(manager.songNotifier.value.length, 11);
      final numbers = manager.songNotifier.value.map((s) => s.number).toList();
      expect(numbers.contains(82), isTrue);
      expect(numbers.contains(115), isTrue);
      expect(numbers.contains(134), isTrue);
      expect(numbers.contains(142), isTrue);
    });

    test('Filtering by category "Мәсіхтің туылуы" returns songs 1 to 9', () async {
      final manager = HomePageManager();
      await manager.init();

      manager.setFilter('Мәсіхтің туылуы');
      expect(manager.songNotifier.value.length, 9);
      final numbers = manager.songNotifier.value.map((s) => s.number).toList();
      expect(numbers, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });

    test('Toggling sort order switches between number and alphabetical order', () async {
      final manager = HomePageManager();
      await manager.init();

      expect(manager.sortByNumberNotifier.value, isTrue);

      await manager.toggleSort();
      expect(manager.sortByNumberNotifier.value, isFalse);

      final songsAlphabetical = manager.songNotifier.value;
      for (int i = 0; i < songsAlphabetical.length - 1; i++) {
        final cmp = songsAlphabetical[i].title.toLowerCase().compareTo(
              songsAlphabetical[i + 1].title.toLowerCase(),
            );
        expect(cmp <= 0, isTrue,
            reason: '${songsAlphabetical[i].title} should precede ${songsAlphabetical[i + 1].title}');
      }
    });
  });
}
