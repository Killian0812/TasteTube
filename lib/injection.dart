import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_tube/storage.dart';

import 'auth/domain/auth_repo.dart';

final getIt = GetIt.instance;

void injectDependencies() {
  // app core instances
  getIt.registerSingleton<Logger>(Logger());
  getIt.registerSingletonAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance());
  getIt.registerSingleton<SecureStorage>(SecureStorage());
  getIt.registerSingleton<LocalStorage>(LocalStorage());

  // repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(
        secureStorage: getIt(),
      ));
}
