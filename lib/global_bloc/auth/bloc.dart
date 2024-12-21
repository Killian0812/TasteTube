import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/storage.dart';
import 'package:taste_tube/utils/user_data.util.dart';

part 'event.dart';
part 'state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final secureStorage = getIt<SecureStorage>();
  final http = getIt<Dio>();

  AuthBloc() : super(Initial()) {
    on<CheckAuthEvent>(_checkAuth);
    on<LoginEvent>(_login);
    on<LogoutEvent>(_logout);
  }

  FutureOr<void> _checkAuth(
      CheckAuthEvent event, Emitter<AuthState> emit) async {
    final refreshToken = await secureStorage.read(key: 'REFRESH_TOKEN');
    if (refreshToken == null) {
      emit(Unauthenticated());
      return;
    }

    try {
      final response = await http.post(
        Api.refreshApi,
        data: {'refreshToken': refreshToken},
      );
      final authData = AuthData.fromJson(response.data);
      http.options.headers['Authorization'] = 'Bearer ${authData.accessToken}';
      emit(Authenticated(authData));
      UserDataUtil.refreshData();
    } on DioException {
      emit(Unauthenticated());
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  void _login(LoginEvent event, Emitter<AuthState> emit) {
    emit(Authenticated(event.data));
    secureStorage.setRefreshToken(event.refreshToken);
    http.options.headers['Authorization'] = 'Bearer ${event.data.accessToken}';
    UserDataUtil.refreshData();
  }

  FutureOr<void> _logout(LogoutEvent event, Emitter<AuthState> emit) async {
    await secureStorage.clearRefreshToken();
    http.options.headers.remove('Authorization');
    emit(Unauthenticated());
  }
}
