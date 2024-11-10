import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/auth/domain/auth_repo.dart';
import 'package:taste_tube/injection.dart';

class OAuthCubit extends Cubit<LoginEmailState> {
  final AuthRepository repository;
  final Logger logger;

  OAuthCubit()
      : repository = getIt<AuthRepository>(),
        logger = getIt<Logger>(),
        super(LoginEmailState());

  Future<void> continueWithFacebook(BuildContext context) async {
    if (state.isLoading) return;
    await repository.continueWithFacebook();
  }

  Future<void> continueWithGoogle(BuildContext context) async {
    if (state.isLoading) return;
    await repository.continueWithGoogle();
  }
}

class LoginEmailState {
  final bool isLoading;

  LoginEmailState({
    this.isLoading = false,
  });
}
