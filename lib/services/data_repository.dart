import 'package:flutter/services.dart' show rootBundle;
import 'package:kazakh_worship/models/category.dart';
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

class AssetDataRepository implements DataRepository {
  List<Song>? _cachedSongs;
  List<PrayerItem>? _cachedPrayers;
  List<GuitarGuideItem>? _cachedGuitarGuides;
  List<SongCategory>? _cachedCategories;

  @override
  Future<List<Song>> getSongs() async {
    if (_cachedSongs != null) return _cachedSongs!;
    try {
      final listText = await rootBundle.loadString('assets/songs/songs_list.txt');
      final lines = listText.split('\n').where((l) => l.trim().isNotEmpty).toList();
      final songs = <Song>[];

      for (final line in lines) {
        final colonIdx = line.indexOf(':');
        final numStr = colonIdx != -1 ? line.substring(0, colonIdx).trim() : line.trim();
        final num = int.tryParse(numStr);
        if (num == null) continue;

        try {
          final content = await rootBundle.loadString('assets/songs/$num.txt');
          songs.add(_parseSong(content, fallbackNumber: num));
        } catch (_) {
          // Continue if single asset fails
        }
      }

      if (songs.isNotEmpty) {
        songs.sort((a, b) => a.number.compareTo(b.number));
        _cachedSongs = List<Song>.unmodifiable(songs);
        return _cachedSongs!;
      }
    } catch (_) {
      // Fallback
    }

    return const [];
  }

  @override
  Future<Song> getSong({required String id}) async {
    final songs = await getSongs();
    return songs.firstWhere((s) => s.id == id);
  }

  @override
  Future<Song?> getSongByNumber(int number) async {
    final songs = await getSongs();
    final matches = songs.where((s) => s.number == number);
    return matches.isNotEmpty ? matches.first : null;
  }

  Song _parseSong(String content, {required int fallbackNumber}) {
    int number = fallbackNumber;
    String title = '';
    String meter = '';
    String category = '';
    String language = 'kk';

    final lines = content.split('\n');
    final chordLines = <String>[];
    bool inHeader = true;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (inHeader && line.startsWith('{') && line.endsWith('}')) {
        final inner = line.substring(1, line.length - 1);
        final colonIdx = inner.indexOf(':');
        if (colonIdx != -1) {
          final key = inner.substring(0, colonIdx).trim().toLowerCase();
          final val = inner.substring(colonIdx + 1).trim();
          switch (key) {
            case 'number':
              number = int.tryParse(val) ?? fallbackNumber;
              break;
            case 'title':
              title = val;
              break;
            case 'meter':
              meter = val;
              break;
            case 'category':
              category = val;
              break;
            case 'language':
              language = val;
              break;
          }
        }
        continue;
      }

      if (inHeader && line.isEmpty) {
        inHeader = false;
        continue;
      }

      inHeader = false;
      chordLines.add(rawLine);
    }

    while (chordLines.isNotEmpty && chordLines.first.trim().isEmpty) {
      chordLines.removeAt(0);
    }
    while (chordLines.isNotEmpty && chordLines.last.trim().isEmpty) {
      chordLines.removeLast();
    }

    final normalizedChordLines = <String>[];
    for (final cl in chordLines) {
      if (cl.trim().isEmpty) {
        if (normalizedChordLines.isNotEmpty && normalizedChordLines.last.isNotEmpty) {
          normalizedChordLines.add('');
        }
      } else {
        normalizedChordLines.add(cl);
      }
    }

    final chords = normalizedChordLines.join('\n');
    final lyricLines = <String>[];
    for (final cl in normalizedChordLines) {
      if (cl.trim().isEmpty) {
        if (lyricLines.isNotEmpty && lyricLines.last.isNotEmpty) {
          lyricLines.add('');
        }
        continue;
      }
      final stripped = cl.replaceAll(RegExp(r'\[.*?\]'), '').trim();
      final nonPunct = stripped.replaceAll(RegExp(r'[()/-:, \t0-9prрxх]'), '');
      if (nonPunct.isEmpty) {
        continue;
      }
      lyricLines.add(stripped);
    }
    while (lyricLines.isNotEmpty && lyricLines.last.isEmpty) {
      lyricLines.removeLast();
    }
    final lyrics = lyricLines.join('\n').trim();

    return Song(
      number: number,
      id: '$number',
      title: title.isNotEmpty ? title : 'Ән #$number',
      meter: meter,
      category: category,
      language: language,
      chords: chords,
      lyrics: lyrics,
    );
  }

  @override
  Future<List<PrayerItem>> getPrayers() async {
    if (_cachedPrayers != null) return _cachedPrayers!;
    try {
      final listText = await rootBundle.loadString('assets/prayers/prayers_list.txt');
      final ids = listText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      final list = <PrayerItem>[];

      for (final id in ids) {
        try {
          final content = await rootBundle.loadString('assets/prayers/$id.txt');
          list.add(_parsePrayer(content, fallbackId: id));
        } catch (_) {}
      }

      if (list.isNotEmpty) {
        _cachedPrayers = List<PrayerItem>.unmodifiable(list);
        return _cachedPrayers!;
      }
    } catch (_) {}

    return const [];
  }

  PrayerItem _parsePrayer(String content, {required String fallbackId}) {
    String id = fallbackId;
    String titleKk = '';
    String? titleMn;
    String? scriptureRef;

    final lines = content.split('\n');
    final kkLines = <String>[];
    final mnLines = <String>[];
    String? currentSection;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (currentSection == null && line.startsWith('{') && line.endsWith('}')) {
        final inner = line.substring(1, line.length - 1);
        final colonIdx = inner.indexOf(':');
        if (colonIdx != -1) {
          final key = inner.substring(0, colonIdx).trim().toLowerCase();
          final val = inner.substring(colonIdx + 1).trim();
          switch (key) {
            case 'id':
              id = val;
              break;
            case 'title_kk':
              titleKk = val;
              break;
            case 'title_mn':
              if (val.isNotEmpty) titleMn = val;
              break;
            case 'scripture':
              if (val.isNotEmpty) scriptureRef = val;
              break;
          }
        }
        continue;
      }

      if (line == '--- kk ---') {
        currentSection = 'kk';
        continue;
      } else if (line == '--- mn ---') {
        currentSection = 'mn';
        continue;
      }

      if (currentSection == 'kk') {
        kkLines.add(rawLine);
      } else if (currentSection == 'mn') {
        mnLines.add(rawLine);
      }
    }

    return PrayerItem(
      id: id,
      titleKk: titleKk.isNotEmpty ? titleKk : fallbackId,
      titleMn: titleMn,
      scriptureRef: scriptureRef,
      contentKk: kkLines.join('\n').trim(),
      contentMn: mnLines.isNotEmpty ? mnLines.join('\n').trim() : null,
    );
  }

  @override
  Future<List<GuitarGuideItem>> getGuitarGuides() async {
    if (_cachedGuitarGuides != null) return _cachedGuitarGuides!;
    try {
      final listText = await rootBundle.loadString('assets/guitar/guitar_list.txt');
      final ids = listText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      final list = <GuitarGuideItem>[];

      for (final id in ids) {
        try {
          final content = await rootBundle.loadString('assets/guitar/$id.txt');
          list.add(_parseGuitarGuide(content, fallbackId: id));
        } catch (_) {}
      }

      if (list.isNotEmpty) {
        _cachedGuitarGuides = List<GuitarGuideItem>.unmodifiable(list);
        return _cachedGuitarGuides!;
      }
    } catch (_) {}

    return const [];
  }

  GuitarGuideItem _parseGuitarGuide(String content, {required String fallbackId}) {
    String id = fallbackId;
    String title = '';
    String subtitle = '';
    final bodyLines = <String>[];
    bool inHeader = true;

    final lines = content.split('\n');
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (inHeader && line.startsWith('{') && line.endsWith('}')) {
        final inner = line.substring(1, line.length - 1);
        final colonIdx = inner.indexOf(':');
        if (colonIdx != -1) {
          final key = inner.substring(0, colonIdx).trim().toLowerCase();
          final val = inner.substring(colonIdx + 1).trim();
          switch (key) {
            case 'id':
              id = val;
              break;
            case 'title':
              title = val;
              break;
            case 'subtitle':
              subtitle = val;
              break;
          }
        }
        continue;
      }

      if (inHeader && line.isEmpty) {
        inHeader = false;
        continue;
      }

      inHeader = false;
      bodyLines.add(rawLine);
    }

    return GuitarGuideItem(
      id: id,
      title: title.isNotEmpty ? title : fallbackId,
      subtitle: subtitle,
      content: bodyLines.join('\n').trim(),
    );
  }

  @override
  Future<List<SongCategory>> getCategories() async {
    if (_cachedCategories != null) return _cachedCategories!;
    try {
      final text = await rootBundle.loadString('assets/categories/categories.txt');
      final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      final list = <SongCategory>[];

      for (final line in lines) {
        final parts = line.split('|');
        if (parts.length >= 2) {
          list.add(SongCategory(
            name: parts[0].trim(),
            scriptureVerse: parts[1].trim(),
          ));
        } else if (parts.isNotEmpty) {
          list.add(SongCategory(
            name: parts[0].trim(),
            scriptureVerse: '',
          ));
        }
      }

      if (list.isNotEmpty) {
        _cachedCategories = List<SongCategory>.unmodifiable(list);
        return _cachedCategories!;
      }
    } catch (_) {}

    return const [];
  }
}
