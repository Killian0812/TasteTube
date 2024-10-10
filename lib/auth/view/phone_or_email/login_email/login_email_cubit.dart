import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/auth/domain/auth_repo.dart';
import 'package:taste_tube/injection.dart';

import '../../../data/register_request.dart';

class LoginEmailCubit extends Cubit<LoginEmailState> {
  final AuthRepository repository;

  LoginEmailCubit()
      : repository = getIt<AuthRepository>(),
        super(LoginEmailState(
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

  Future<void> send() async {
    final request = RegisterRequest(state.email, state.password);

    final result = await repository.register(request);
    result.match(
      (apiError) {
        print('Registration failed: ${apiError.message}');
      },
      (response) {
        print('Registration successful: ${response.accessToken}');
      },
    );
  }

  PasswordValidation validatePassword(String password) {
    bool hasMinLength = password.length >= 8 && password.length <= 20;
    bool hasLetterAndNumber =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password);
    bool hasSpecialChar = RegExp(r'[!@#\$&*~]').hasMatch(password);

    int strengthScore = (hasMinLength ? 1 : 0) +
        (hasLetterAndNumber ? 1 : 0) +
        (hasSpecialChar ? 1 : 0);

    PasswordStrength strength;
    if (strengthScore == 3) {
      strength = PasswordStrength.strong;
    } else if (strengthScore == 2) {
      strength = PasswordStrength.medium;
    } else {
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

class LoginEmailState {
  final String email;
  final String password;
  final String confirmPassword;
  final bool isPasswordVisible;

  LoginEmailState({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.isPasswordVisible,
  });

  LoginEmailState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    bool? isPasswordVisible,
  }) {
    return LoginEmailState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }
}

enum PasswordStrength { weak, medium, strong }

class PasswordValidation {
  final bool hasMinLength;
  final bool hasLetterAndNumber;
  final bool hasSpecialChar;
  final PasswordStrength strength;

  PasswordValidation({
    required this.hasMinLength,
    required this.hasLetterAndNumber,
    required this.hasSpecialChar,
    required this.strength,
  });
}
