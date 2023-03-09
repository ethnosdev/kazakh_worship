import 'package:flutter/material.dart';
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
  final manager = getIt<ThemeManager>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Kazakh worship songs'),
          actions: [
            IconButton(
              onPressed: () {
                manager.toggleTheme();
              },
              icon: (manager.isDark)
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
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('song name'),
                    onTap: () {
                      print('song $index');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SongPage()),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ));
  }
}
