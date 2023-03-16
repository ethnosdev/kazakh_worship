import 'package:get_it/get_it.dart';
import 'package:kazakh_worship/services/data_repository.dart';
import 'package:kazakh_worship/theme_manager.dart';

final getIt = GetIt.instance;

void setupServiceLocater() {
  getIt.registerLazySingleton<ThemeManager>(() => ThemeManager());
  getIt.registerLazySingleton<DataRepository>(() => FakeData());
}
