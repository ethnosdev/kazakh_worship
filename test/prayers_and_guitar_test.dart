import 'package:flutter_test/flutter_test.dart';
import 'package:kazakh_worship/data/categories_data.dart';
import 'package:kazakh_worship/data/guitar_data.dart';
import 'package:kazakh_worship/data/prayers_data.dart';

void main() {
  group('Prayers and Guitar Guide Tests', () {
    test('Prayers data contains all 6 required sections from book', () {
      expect(prayerList.length, 6);

      final ids = prayerList.map((p) => p.id).toList();
      expect(ids.contains('apostles_creed'), isTrue);
      expect(ids.contains('lords_prayer'), isTrue);
      expect(ids.contains('repentance'), isTrue);
      expect(ids.contains('sunday_service'), isTrue);
      expect(ids.contains('home_church'), isTrue);
      expect(ids.contains('family_prayer'), isTrue);
    });

    test('Apostles Creed, Lord Prayer, and Repentance have Mongolian versions', () {
      final creed = prayerList.firstWhere((p) => p.id == 'apostles_creed');
      expect(creed.contentKk.isNotEmpty, isTrue);
      expect(creed.contentMn?.isNotEmpty, isTrue);
      expect(creed.titleMn, 'Итгэлийн тунхаг');

      final prayer = prayerList.firstWhere((p) => p.id == 'lords_prayer');
      expect(prayer.contentKk.isNotEmpty, isTrue);
      expect(prayer.contentMn?.isNotEmpty, isTrue);
      expect(prayer.titleMn, 'Тэнгэр дэх, бидний Аав аа');

      final repentance = prayerList.firstWhere((p) => p.id == 'repentance');
      expect(repentance.contentKk.isNotEmpty, isTrue);
      expect(repentance.contentMn?.isNotEmpty, isTrue);
    });

    test('Guitar Guide contains 3 sections from book', () {
      expect(guitarGuideList.length, 3);
      final ids = guitarGuideList.map((g) => g.id).toList();
      expect(ids.contains('tuning'), isTrue);
      expect(ids.contains('strumming'), isTrue);
      expect(ids.contains('intro'), isTrue);

      for (final g in guitarGuideList) {
        expect(g.title.isNotEmpty, isTrue);
        expect(g.content.isNotEmpty, isTrue);
      }
    });

    test('Categories data contains all songbook categories with verses', () {
      expect(categoryList.length, 19);
      for (final cat in categoryList) {
        expect(cat.name.isNotEmpty, isTrue);
        expect(cat.scriptureVerse.isNotEmpty, isTrue);
      }
    });
  });
}
