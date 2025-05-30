import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/auth/domain/auth_repo.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/core/injection.dart';

import '../../../data/login_request.dart';

class LoginEmailCubit extends Cubit<LoginEmailState> {
  final AuthRepository repository;
  final Logger logger;

  LoginEmailCubit()
      : repository = getIt<AuthRepository>(),
        logger = getIt<Logger>(),
        super(LoginEmailInitial());

  void editEmail(String email) {
    emit(LoginEmailLoaded(email, state.password, state.isPasswordVisible));
  }

  void editPassword(String password) {
    emit(LoginEmailLoaded(state.email, password, state.isPasswordVisible));
  }

  void togglePasswordVisibility() {
    emit(LoginEmailLoaded(
        state.email, state.password, !state.isPasswordVisible));
  }

  Future<void> send() async {
    if (state is LoginEmailLoading) return;
    emit(LoginEmailLoading(
        state.email, state.password, state.isPasswordVisible));
    final request = LoginRequest(state.email, state.password);
    final result = await repository.login(request);
    result.match(
      (apiError) {
        logger.e('Login failed: ${apiError.message}');
        emit(LoginEmailError(state.email, state.password,
            state.isPasswordVisible, apiError.message!));
      },
      (response) async {
        logger.i('Login successfully: ${response.accessToken}');
        getIt<AuthBloc>().add(LoginEvent(response));
        emit(LoginEmailSuccess(
          state.email,
          state.password,
          state.isPasswordVisible,
          "Login successfully! Redirecting to home page...",
          response,
        ));
      },
    );
  }
}

abstract class LoginEmailState {
  final String email;
  final String password;
  final bool isPasswordVisible;
  final String? message;
  final AuthData? response;

  const LoginEmailState({
    required this.email,
    required this.password,
    required this.isPasswordVisible,
    this.message,
    this.response,
  });
}

class LoginEmailInitial extends LoginEmailState {
  LoginEmailInitial()
      : super(
          email: '',
          password: '',
          isPasswordVisible: false,
        );
}

class LoginEmailLoading extends LoginEmailState {
  const LoginEmailLoading(String email, String password, bool isPasswordVisible)
      : super(
          email: email,
          password: password,
          isPasswordVisible: isPasswordVisible,
        );
}

class LoginEmailLoaded extends LoginEmailState {
  const LoginEmailLoaded(String email, String password, bool isPasswordVisible)
      : super(
          email: email,
          password: password,
          isPasswordVisible: isPasswordVisible,
        );
}

class LoginEmailSuccess extends LoginEmailState {
  final String success;
  final AuthData authData;

  const LoginEmailSuccess(String email, String password, bool isPasswordVisible,
      this.success, this.authData)
      : super(
          email: email,
          password: password,
          isPasswordVisible: isPasswordVisible,
          message: success,
          response: authData,
        );
}

class LoginEmailError extends LoginEmailState {
  final String error;

  const LoginEmailError(
      String email, String password, bool isPasswordVisible, this.error)
      : super(
          email: email,
          password: password,
          isPasswordVisible: isPasswordVisible,
          message: error,
        );
}
