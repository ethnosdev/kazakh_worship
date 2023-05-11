import 'package:flutter/material.dart';
import 'package:kazakh_worship/home/home_page.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:kazakh_worship/theme_manager.dart';

Future<void> main() async {
  setupServiceLocater();
  final manager = getIt<ThemeManager>();
  await manager.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final manager = getIt<ThemeManager>();

  @override
  void initState() {
    super.initState();
    manager.init();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
        valueListenable: manager.themeListener,
        builder: (context, theme, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const HomePage(),
          );
        });
  }
}
