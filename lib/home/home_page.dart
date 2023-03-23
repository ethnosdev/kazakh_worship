import 'package:flutter/material.dart';
import 'package:kazakh_worship/home/home_page_manager.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:kazakh_worship/song/song_page.dart';
import 'package:kazakh_worship/theme_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final themeManager = getIt<ThemeManager>();
  final manager = HomePageManager();

  @override
  void initState() {
    super.initState();
    manager.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Kazakh worship songs'),
          actions: [
            IconButton(
              onPressed: () {
                themeManager.toggleTheme();
              },
              icon: (themeManager.isDark)
                  ? Icon(Icons.light_mode)
                  : Icon(Icons.dark_mode),
            ),
          ],
        ),
        body: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                manager.search(value);
              },
            ),
            Expanded(
              child: ValueListenableBuilder<List<String>>(
                  valueListenable: manager.songNotifier,
                  builder: (context, titles, child) {
                    return ListView.builder(
                      itemCount: titles.length,
                      itemBuilder: (context, index) {
                        final title = titles[index];
                        return ListTile(
                          title: Text(title),
                          onTap: () {
                            print('song $index');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SongPage()),
                            );
                          },
                        );
                      },
                    );
                  }),
            ),
          ],
        ));
  }
}
