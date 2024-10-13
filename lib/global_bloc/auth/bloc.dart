import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/injection.dart';
import 'package:http/http.dart' as http;
import 'package:taste_tube/storage.dart';

part 'event.dart';
part 'state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final secureStorage = getIt<SecureStorage>();

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

    final response = await http.post(
      Uri.parse(Api.refreshApi),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final authData = AuthData.fromJson(responseData);
      emit(Authenticated(authData));
    } else {
      emit(Unauthenticated());
    }
  }

  FutureOr<void> _login(LoginEvent event, Emitter<AuthState> emit) async {
    await secureStorage.setRefreshToken(event.refreshToken);
    emit(Authenticated(event.data));
  }

  FutureOr<void> _logout(LogoutEvent event, Emitter<AuthState> emit) async {
    await secureStorage.clearRefreshToken();
    emit(Unauthenticated());
  }
}
