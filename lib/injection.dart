import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/feature/product/domain/product_repo.dart';
import 'package:taste_tube/feature/profile/domain/profile_repo.dart';
import 'package:taste_tube/feature/upload/domain/upload_repo.dart';
import 'package:taste_tube/storage.dart';
import 'package:uuid/uuid.dart';

import 'auth/domain/auth_repo.dart';

final getIt = GetIt.instance;

void injectDependencies() {
  // App core instances
  getIt.registerSingleton<Logger>(Logger());
  getIt.registerSingleton<Dio>(Dio(BaseOptions(
    baseUrl: Api.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  )));
  getIt.registerSingleton<SecureStorage>(SecureStorage());
  getIt.registerSingleton<LocalStorage>(LocalStorage());
  getIt.registerSingleton<Uuid>(const Uuid());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(
        secureStorage: getIt(),
        http: getIt(),
      ));
  getIt.registerLazySingleton<UploadRepository>(() => UploadRepository(
        http: getIt(),
      ));
  getIt.registerLazySingleton<UserRepository>(() => UserRepository(
        http: getIt(),
      ));
  getIt.registerLazySingleton<ProductRepository>(() => ProductRepository(
        http: getIt(),
      ));
}
