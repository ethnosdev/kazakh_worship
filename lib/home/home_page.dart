import 'package:flutter/material.dart';
import 'package:kazakh_worship/song/song_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Kazakh worship songs'),
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
