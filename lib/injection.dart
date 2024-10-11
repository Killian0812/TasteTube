import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'auth/domain/auth_repo.dart';

final getIt = GetIt.instance;

void injectDependencies() {
  getIt.registerSingleton<Logger>(Logger());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
}
