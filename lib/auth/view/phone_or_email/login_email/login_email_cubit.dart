import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/auth/domain/auth_repo.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/global_bloc/auth/bloc.dart';
import 'package:taste_tube/injection.dart';

import '../../../data/login_request.dart';

class LoginEmailCubit extends Cubit<LoginEmailState> {
  final AuthRepository repository;
  final Logger logger;

  LoginEmailCubit()
      : repository = getIt<AuthRepository>(),
        logger = getIt<Logger>(),
        super(LoginEmailState(
          email: "",
          password: "",
          isPasswordVisible: false,
        ));

  void editEmail(String email) {
    emit(state.copyWith(email: email));
  }

  void editPassword(String password) {
    emit(state.copyWith(password: password));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> send(BuildContext context) async {
    final request = LoginRequest(state.email, state.password);
    final result = await repository.login(request);
    result.match(
      (apiError) {
        ToastService.showToast(context, apiError.message!,
            apiError.statusCode < 500 ? ToastType.warning : ToastType.error,
            duration: const Duration(seconds: 4));
        logger.e('Login failed: ${apiError.message}');
      },
      (response) {
        ToastService.showToast(
            context,
            "Login successfully! Redirecting to home page...",
            ToastType.success,
            duration: const Duration(seconds: 4));
        context.read<AuthBloc>().add(LoginEvent(AuthData(
              accessToken: response.accessToken,
              email: response.email,
              username: response.username,
              image: response.image,
              userId: response.userId,
            )));
        context.go('/home');
        logger.i('Login successfully: ${response.accessToken}');
      },
    );
  }
}

class LoginEmailState {
  final String email;
  final String password;
  final bool isPasswordVisible;

  LoginEmailState({
    required this.email,
    required this.password,
    required this.isPasswordVisible,
  });

  LoginEmailState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
  }) {
    return LoginEmailState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }
}
