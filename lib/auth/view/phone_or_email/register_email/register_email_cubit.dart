import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/auth/domain/auth_repo.dart';
import 'package:taste_tube/auth/view/register_page.ext.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/core/injection.dart';

import '../../../data/register_request.dart';

class RegisterEmailCubit extends Cubit<RegisterEmailState> {
  final AuthRepository repository;
  final Logger logger;

  RegisterEmailCubit()
      : repository = getIt<AuthRepository>(),
        logger = getIt<Logger>(),
        super(RegisterEmailState(
          email: "",
          password: "",
          confirmPassword: "",
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

  void editConfirmPassword(String confirmPassword) {
    emit(state.copyWith(confirmPassword: confirmPassword));
  }

  void clearFields() {
    emit(state.copyWith(email: "", password: "", confirmPassword: ""));
  }

  Future<void> send(BuildContext context) async {
    emit(state.copyWith(sending: true));

    final request = RegisterRequest(state.email, state.password);

    final result = await repository.register(request);

    emit(state.copyWith(sending: false));

    result.match((apiError) {
      ToastService.showToast(context, apiError.message!,
          apiError.statusCode < 500 ? ToastType.warning : ToastType.error,
          duration: const Duration(seconds: 4));
      logger.e('Registration failed: ${apiError.message}');
    }, (response) {
      emit(state.copyWith(succeed: true));
      ToastService.showToast(
          context,
          "Registration successful! Let's customize your account...",
          ToastType.success,
          duration: const Duration(seconds: 4));
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AccountTypeSelectionPage.provider(response.userId)),
          );
        }
      });
      logger.i('Registration successful');
    });
  }

  Future<void> setRole(BuildContext context, String role, String userId) async {
    final request = SetRoleRequest(userId, role);

    final result = await repository.setRole(request);
    result.match((apiError) {
      ToastService.showToast(context, apiError.message!,
          apiError.statusCode < 500 ? ToastType.warning : ToastType.error,
          duration: const Duration(seconds: 4));
      logger.e('Set role failed: ${apiError.message}');
    }, (response) {
      emit(state.copyWith(succeed: true));
      ToastService.showToast(context,
          "Account type selected. Redirecting to login...", ToastType.success,
          duration: const Duration(seconds: 4));
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) context.go('/login', extra: 1);
      });
      logger.i('Account type selected: $response');
    });
  }

  PasswordValidation validatePassword(String password) {
    bool hasMinLength = password.length >= 6 && password.length <= 20;
    bool hasLetterAndNumber =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password);
    bool hasSpecialChar = RegExp(r'[!@#\$&*~]').hasMatch(password);

    int strengthScore = (hasMinLength ? 1 : 0) +
        (hasLetterAndNumber ? 1 : 0) +
        (hasSpecialChar ? 1 : 0);

    PasswordStrength? strength;
    if (strengthScore == 3) {
      strength = PasswordStrength.strong;
    } else if (strengthScore == 2) {
      strength = PasswordStrength.medium;
    } else if (strengthScore == 1) {
      strength = PasswordStrength.weak;
    }

    return PasswordValidation(
      hasMinLength: hasMinLength,
      hasLetterAndNumber: hasLetterAndNumber,
      hasSpecialChar: hasSpecialChar,
      strength: strength,
    );
  }
}

class RegisterEmailState {
  final String email;
  final String password;
  final String confirmPassword;
  final bool isPasswordVisible;
  final bool sending;
  final bool succeed;

  RegisterEmailState({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.isPasswordVisible,
    this.succeed = false,
    this.sending = false,
  });

  RegisterEmailState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    bool? isPasswordVisible,
    bool? succeed,
    bool? sending,
  }) {
    return RegisterEmailState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      succeed: succeed ?? this.succeed,
      sending: sending ?? this.sending,
    );
  }
}

enum PasswordStrength { weak, medium, strong }

class PasswordValidation {
  final bool hasMinLength;
  final bool hasLetterAndNumber;
  final bool hasSpecialChar;
  final PasswordStrength? strength;

  PasswordValidation({
    required this.hasMinLength,
    required this.hasLetterAndNumber,
    required this.hasSpecialChar,
    required this.strength,
  });
}
