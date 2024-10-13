import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/storage.dart';

import 'auth/domain/auth_repo.dart';

final getIt = GetIt.instance;

void injectDependencies() {
  // app core instances
  getIt.registerSingleton<Logger>(Logger());
  getIt.registerSingleton<Dio>(Dio(BaseOptions(
    baseUrl: Api.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {'Content-Type': 'application/json'},
  )));
  getIt.registerSingleton<SecureStorage>(SecureStorage());
  getIt.registerSingleton<LocalStorage>(LocalStorage());

  // repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(
        secureStorage: getIt(),
        http: getIt(),
      ));
}
