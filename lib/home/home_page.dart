import 'package:flutter/material.dart';
import 'package:kazakh_worship/guitar/guitar_guide_page.dart';
import 'package:kazakh_worship/home/home_page_manager.dart';
import 'package:kazakh_worship/models/song.dart';
import 'package:kazakh_worship/prayers/prayers_page.dart';
import 'package:kazakh_worship/settings/settings_page.dart';
import 'package:kazakh_worship/song/song_page.dart';
import 'package:kazakh_worship/song/widgets/jump_to_song_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final manager = HomePageManager();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    manager.init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Тақырыптарды таңдау / Choose Category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: manager.categoriesNotifier.value.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: const Icon(Icons.all_inclusive),
                        title: const Text('Барлық тақырыптар (All)'),
                        onTap: () {
                          manager.setFilter('all');
                          Navigator.pop(context);
                        },
                      );
                    }
                    final cat = manager.categoriesNotifier.value[index - 1];
                    return ListTile(
                      leading: const Icon(Icons.bookmark_border),
                      title: Text(cat.name),
                      subtitle: Text(
                        cat.scriptureVerse,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        manager.setFilter(cat.name);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Құдайға мадақтайық'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: manager.sortByNumberNotifier,
            builder: (context, sortByNumber, child) {
              return IconButton(
                icon: Icon(
                  sortByNumber
                      ? Icons.format_list_numbered
                      : Icons.sort_by_alpha,
                ),
                tooltip: sortByNumber
                    ? 'Әліпби бойынша сұрыптау'
                    : 'Нөмір бойынша сұрыптау',
                onPressed: () => manager.toggleSort(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tag),
            tooltip: 'Ән нөміріне өту',
            onPressed: () {
              final navigator = Navigator.of(context);
              JumpToSongDialog.show(
                context,
                maxSongNumber: 142,
                onSongSelected: (number) async {
                  final song = await manager.dataRepo.getSongByNumber(number);
                  if (song != null && mounted) {
                    navigator.push(
                      MaterialPageRoute(
                        builder: (context) => SongPage(song: song),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 38,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Құдайға мадақ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'Рухани әндер мен дұғалар',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.auto_stories),
                title: const Text('Дұғалар', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Сенім белгісі және жиналыс реттілігі'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrayersPage(),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.queue_music),
                title: const Text('Гитара үйрену', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Көктеу, шерту және ырғақ'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GuitarGuidePage(),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Баптаулар', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Қаріп өлшемі, тақырып / Settings'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: _buildSongsTab(),
    );
  }

  Widget _buildSongsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Ән нөмірі, аты немесе мәтіні...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        manager.search('');
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              manager.search(value);
              setState(() {});
            },
          ),
        ),
        ValueListenableBuilder<String>(
          valueListenable: manager.selectedFilterNotifier,
          builder: (context, selectedFilter, child) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Барлығы'),
                    selected: selectedFilter == 'all',
                    onSelected: (selected) {
                      if (selected) manager.setFilter('all');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Қазақша'),
                    selected: selectedFilter == 'kk',
                    onSelected: (selected) {
                      if (selected) manager.setFilter('kk');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Монгол'),
                    selected: selectedFilter == 'mn',
                    onSelected: (selected) {
                      if (selected) manager.setFilter('mn');
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.category, size: 16),
                    label: Text(
                      selectedFilter != 'all' &&
                              selectedFilter != 'kk' &&
                              selectedFilter != 'mn'
                          ? selectedFilter
                          : 'Тақырыптар',
                    ),
                    onPressed: _showCategoryPicker,
                  ),
                ],
              ),
            );
          },
        ),
        Expanded(
          child: ValueListenableBuilder<List<Song>>(
            valueListenable: manager.songNotifier,
            builder: (context, songs, child) {
              if (songs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ән табылмады',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      child: Text(
                        '${song.number}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: song.category.isNotEmpty || song.meter.isNotEmpty
                        ? Text(
                            [
                              if (song.category.isNotEmpty) song.category,
                              if (song.meter.isNotEmpty) song.meter,
                            ].join(' • '),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          )
                        : null,
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongPage(song: song),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
