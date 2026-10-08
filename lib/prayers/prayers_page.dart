import 'package:flutter/material.dart';
import 'package:kazakh_worship/models/prayer.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:kazakh_worship/services/data_repository.dart';

class PrayersPage extends StatefulWidget {
  const PrayersPage({super.key});

  @override
  State<PrayersPage> createState() => _PrayersPageState();
}

class _PrayersPageState extends State<PrayersPage> {
  final dataRepo = getIt<DataRepository>();
  List<PrayerItem> _prayers = [];
  bool _isLoading = true;
  // Selected language per prayer id: 'kk' or 'mn'
  final Map<String, String> _languageSelection = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await dataRepo.getPrayers();
    if (mounted) {
      setState(() {
        _prayers = list;
        for (final p in list) {
          _languageSelection[p.id] = 'kk';
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: _prayers.length,
      itemBuilder: (context, index) {
        final prayer = _prayers[index];
        final lang = _languageSelection[prayer.id] ?? 'kk';
        final hasMn = prayer.contentMn != null && prayer.contentMn!.isNotEmpty;
        final content = (lang == 'mn' && hasMn) ? prayer.contentMn! : prayer.contentKk;
        final title = (lang == 'mn' && hasMn && prayer.titleMn != null)
            ? prayer.titleMn!
            : prayer.titleKk;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (prayer.scriptureRef != null && prayer.scriptureRef!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                prayer.scriptureRef!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (hasMn)
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'kk', label: Text('ҚАЗ')),
                          ButtonSegment(value: 'mn', label: Text('МОН')),
                        ],
                        selected: {lang},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            _languageSelection[prayer.id] = newSelection.first;
                          });
                        },
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
                const Divider(height: 24),
                SelectableText(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
