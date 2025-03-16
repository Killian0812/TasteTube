import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/global_bloc/socket/socket_provider.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/storage.dart';
import 'package:taste_tube/utils/user_data.util.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final secureStorage = getIt<SecureStorage>();
  final http = getIt<Dio>();

  AuthBloc() : super(Initial()) {
    on<CheckAuthEvent>(_checkAuth);
    on<UpdateCurrencyEvent>(_updateCurrency);
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
      getIt<SocketProvider>().initSocket(authData.userId);
      UserDataUtil.refreshData();
    } on DioException {
      emit(Unauthenticated());
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  void _login(LoginEvent event, Emitter<AuthState> emit) async {
    emit(Authenticated(event.data));
    await secureStorage.setRefreshToken(event.refreshToken);
    http.options.headers['Authorization'] = 'Bearer ${event.data.accessToken}';
    getIt<SocketProvider>().initSocket(event.data.userId);
    UserDataUtil.refreshData();
  }

  void _updateCurrency(UpdateCurrencyEvent event, Emitter<AuthState> emit) {
    final authData = state.data!.copyWith(currency: event.currency);
    emit(Authenticated(authData));
  }

  FutureOr<void> _logout(LogoutEvent event, Emitter<AuthState> emit) async {
    getIt<SocketProvider>().disconnectSocket();
    FacebookAuth.instance.logOut();
    await FacebookAuth.instance.logOut();
    await secureStorage.clearRefreshToken();
    http.options.headers.remove('Authorization');
    emit(Unauthenticated());
  }
}
