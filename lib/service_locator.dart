import 'package:get_it/get_it.dart';
import 'package:kazakh_worship/services/data_repository.dart';
import 'package:kazakh_worship/theme_manager.dart';
import 'package:kazakh_worship/user_settings.dart';

final getIt = GetIt.instance;

void setupServiceLocater() {
  getIt.registerLazySingleton<UserSettings>(() => UserSettings());
  getIt.registerLazySingleton<ThemeManager>(() => ThemeManager());
  getIt.registerLazySingleton<DataRepository>(() => FakeData());
}
