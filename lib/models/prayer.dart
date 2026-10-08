class PrayerItem {
  final String id;
  final String titleKk;
  final String? titleMn;
  final String contentKk;
  final String? contentMn;
  final String? scriptureRef;

  const PrayerItem({
    required this.id,
    required this.titleKk,
    this.titleMn,
    required this.contentKk,
    this.contentMn,
    this.scriptureRef,
  });
}
