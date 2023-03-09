import 'package:flutter/material.dart';
import 'package:kazakh_worship/home/home_page.dart';
import 'package:kazakh_worship/service_locator.dart';
import 'package:kazakh_worship/theme_manager.dart';

void main() {
  setupServiceLocater();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final manager = getIt<ThemeManager>();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
        valueListenable: manager.themeListener,
        builder: (context, theme, child) {
          print('building');
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: HomePage(),
          );
        });
  }
}
