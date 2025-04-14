import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/fcm_service.dart';
import 'package:taste_tube/global_bloc/getstream/getstream_cubit.dart';
import 'package:taste_tube/global_bloc/realtime/realtime_provider.dart';
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
      await secureStorage.setRefreshToken(authData.refreshToken);
      http.options.headers['Authorization'] = 'Bearer ${authData.accessToken}';
      emit(Authenticated(authData));
      getIt<RealtimeProvider>().initSocket(authData.userId);
      getIt<GetstreamCubit>().initializeClient(authData);
      UserDataUtil.refreshData();
      FCMService.updateFcmToken();
    } on DioException {
      emit(Unauthenticated());
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  void _login(LoginEvent event, Emitter<AuthState> emit) async {
    emit(Authenticated(event.data));
    await secureStorage.setRefreshToken(event.data.refreshToken);
    http.options.headers['Authorization'] = 'Bearer ${event.data.accessToken}';
    getIt<RealtimeProvider>().initSocket(event.data.userId);
    getIt<GetstreamCubit>()
        .initializeClient(event.data);
    UserDataUtil.refreshData();
    FCMService.updateFcmToken();
  }

  void _updateCurrency(UpdateCurrencyEvent event, Emitter<AuthState> emit) {
    final authData = state.data!.copyWith(currency: event.currency);
    emit(Authenticated(authData));
  }

  FutureOr<void> _logout(LogoutEvent event, Emitter<AuthState> emit) async {
    final logger = getIt<Logger>();

    // Attempt to clear refresh token
    try {
      await secureStorage.clearRefreshToken();
      http.options.headers.remove('Authorization');
    } catch (e) {
      logger.e('Failed to clear refresh token & authorization header: $e');
    }

    // Disconnect socket
    try {
      getIt<RealtimeProvider>().disconnectSocket();
    } catch (e) {
      logger.e('Failed to disconnect socket: $e');
    }

    // Facebook logout
    try {
      final userData = await FacebookAuth.instance.getUserData();
      if (userData["name"] != null && (userData["name"] as String).isNotEmpty) {
        await FacebookAuth.instance.logOut();
      }
    } catch (e) {
      logger.e('Failed to logout from Facebook: $e');
    }

    // Google logout
    try {
      await getIt<GoogleSignIn>().signOut();
    } catch (e) {
      logger.e('Failed to logout from Google: $e');
    }

    emit(Unauthenticated());
  }
}
