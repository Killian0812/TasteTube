import 'package:get_it/get_it.dart';

import 'auth/domain/auth_repo.dart';

final getIt = GetIt.instance;

void injectDependencies() {
  getIt.registerSingleton<AuthRepository>(AuthRepository());
}
