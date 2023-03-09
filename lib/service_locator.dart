import 'package:get_it/get_it.dart';
import 'package:kazakh_worship/theme_manager.dart';

final getIt = GetIt.instance;

void setupServiceLocater() {
  getIt.registerLazySingleton<ThemeManager>(() => ThemeManager());
}
