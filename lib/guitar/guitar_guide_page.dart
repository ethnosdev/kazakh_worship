import 'package:flutter/material.dart';
import 'package:kazakh_worship/models/guitar_guide.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:kazakh_worship/services/data_repository.dart';

class GuitarGuidePage extends StatefulWidget {
  const GuitarGuidePage({super.key});

  @override
  State<GuitarGuidePage> createState() => _GuitarGuidePageState();
}

class _GuitarGuidePageState extends State<GuitarGuidePage> {
  final dataRepo = getIt<DataRepository>();
  List<GuitarGuideItem> _guides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await dataRepo.getGuitarGuides();
    if (mounted) {
      setState(() {
        _guides = list;
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
      itemCount: _guides.length,
      itemBuilder: (context, index) {
        final guide = _guides[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.music_note),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guide.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (guide.subtitle.isNotEmpty)
                            Text(
                              guide.subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                SelectableText(
                  guide.content,
                  style: const TextStyle(
                    fontSize: 15,
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
