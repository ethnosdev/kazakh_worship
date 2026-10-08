import 'package:flutter/material.dart';
import 'package:kazakh_worship/data/categories_data.dart';
import 'package:kazakh_worship/models/song.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:kazakh_worship/services/data_repository.dart';
import 'package:kazakh_worship/user_settings.dart';

class HomePageManager {
  final songNotifier = ValueNotifier<List<Song>>([]);
  final sortByNumberNotifier = ValueNotifier<bool>(true);
  final selectedFilterNotifier = ValueNotifier<String>('all');
  final categoriesNotifier = ValueNotifier<List<SongCategory>>([]);

  final dataRepo = getIt<DataRepository>();
  final userSettings = getIt<UserSettings>();

  List<Song> _allSongs = [];
  String _currentQuery = '';

  Future<void> init() async {
    _allSongs = await dataRepo.getSongs();
    categoriesNotifier.value = await dataRepo.getCategories();
    sortByNumberNotifier.value = await userSettings.getSortByNumber();
    _applyFilters();
  }

  void search(String query) {
    _currentQuery = query.trim();
    _applyFilters();
  }

  Future<void> toggleSort() async {
    final newValue = !sortByNumberNotifier.value;
    sortByNumberNotifier.value = newValue;
    await userSettings.setSortByNumber(newValue);
    _applyFilters();
  }

  void setFilter(String filter) {
    selectedFilterNotifier.value = filter;
    _applyFilters();
  }

  void _applyFilters() {
    List<Song> filtered = List.from(_allSongs);

    // 1. Language / Category Filter
    final filter = selectedFilterNotifier.value;
    if (filter == 'kk') {
      filtered = filtered.where((s) => s.language == 'kk').toList();
    } else if (filter == 'mn') {
      filtered = filtered.where((s) => s.language == 'mn').toList();
    } else if (filter != 'all') {
      filtered = filtered.where((s) => s.category == filter).toList();
    }

    // 2. Search Query (Number, Title, Lyrics)
    if (_currentQuery.isNotEmpty) {
      final qLower = _currentQuery.toLowerCase();
      final qNum = int.tryParse(_currentQuery);

      filtered = filtered.where((s) {
        // Match exact number or number starts with query
        if (qNum != null && (s.number == qNum || s.number.toString().startsWith(_currentQuery))) {
          return true;
        }
        // Match title
        if (s.title.toLowerCase().contains(qLower)) {
          return true;
        }
        // Match lyrics
        if (s.lyrics.toLowerCase().contains(qLower)) {
          return true;
        }
        return false;
      }).toList();

      // If user typed an exact number, place the exact match at the top!
      if (qNum != null) {
        filtered.sort((a, b) {
          if (a.number == qNum && b.number != qNum) return -1;
          if (b.number == qNum && a.number != qNum) return 1;
          return a.number.compareTo(b.number);
        });
      }
    }

    // 3. Sorting (if not searching by exact number)
    final qNum = int.tryParse(_currentQuery);
    if (qNum == null) {
      if (sortByNumberNotifier.value) {
        filtered.sort((a, b) => a.number.compareTo(b.number));
      } else {
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      }
    }

    songNotifier.value = filtered;
  }
}
