class Song {
  final int number;
  final String id;
  final String title;
  final String lyrics;
  final String chords;
  final String meter;
  final String category;
  final String language; // 'kk' or 'mn'

  const Song({
    required this.number,
    required this.id,
    required this.title,
    required this.lyrics,
    required this.chords,
    this.meter = '',
    this.category = '',
    this.language = 'kk',
  });
}
