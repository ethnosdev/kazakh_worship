import 'package:flutter/material.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:kazakh_worship/theme_manager.dart';
import 'package:kazakh_worship/user_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final themeManager = getIt<ThemeManager>();
  final userSettings = getIt<UserSettings>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Баптаулар'),
      ),
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: Listenable.merge([
            themeManager.themeModeNotifier,
            userSettings.fontSizeNotifier,
          ]),
          builder: (context, _) {
            final themeMode = themeManager.themeMode;
            final fontSize = userSettings.fontSize;

            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    'Көрініс',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ListTile(
                  title: const Text('Ашық-күңгірт режим'),
                  subtitle: Text(
                    themeMode == ThemeMode.light
                        ? 'Ашық'
                        : themeMode == ThemeMode.dark
                            ? 'Күңгірт'
                            : 'Құрылғы баптаулары бойынша',
                  ),
                  trailing: Icon(
                    themeMode == ThemeMode.light
                        ? Icons.light_mode
                        : themeMode == ThemeMode.dark
                            ? Icons.dark_mode
                            : Icons.smartphone,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        insetPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 16,
                        ),
                        content: SegmentedButton<ThemeMode>(
                          style: SegmentedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                          ),
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.light,
                              label: Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.light_mode),
                                    SizedBox(height: 4),
                                    Text('Ашық'),
                                  ],
                                ),
                              ),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.system,
                              label: Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.smartphone),
                                    SizedBox(height: 4),
                                    Text('Құрылғы'),
                                  ],
                                ),
                              ),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.dark,
                              label: Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.dark_mode),
                                    SizedBox(height: 4),
                                    Text('Күңгірт'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          selected: {themeMode},
                          onSelectionChanged: (Set<ThemeMode> selection) {
                            themeManager.setThemeMode(selection.first);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Қаріп өлшемі'),
                  trailing: Text(
                    '${fontSize.round()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    double currentSize = fontSize;
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: SizedBox(
                          height: 150,
                          child: StatefulBuilder(
                            builder: (context, setDialogState) => Column(
                              children: [
                                const Spacer(),
                                Text(
                                  'Қаріп өлшемі',
                                  style: TextStyle(fontSize: currentSize),
                                ),
                                const Spacer(),
                                Slider(
                                  value: currentSize.clamp(10.0, 40.0),
                                  min: 10.0,
                                  max: 40.0,
                                  divisions: 30,
                                  label: currentSize.toStringAsFixed(1),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      currentSize = value;
                                    });
                                    userSettings.setFontSizePreview(value);
                                  },
                                  onChangeEnd: (value) {
                                    userSettings.setFontSize(value);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
