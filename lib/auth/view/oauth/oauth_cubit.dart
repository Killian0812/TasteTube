import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/auth/data/login_response.dart';
import 'package:taste_tube/auth/domain/auth_repo.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/storage.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class OAuthCubit extends Cubit<OAuthState> {
  final AuthRepository repository;
  final Logger logger;
  final SecureStorage secureStorage;

  OAuthCubit()
      : repository = getIt<AuthRepository>(),
        secureStorage = getIt<SecureStorage>(),
        logger = getIt<Logger>(),
        super(const OAuthLoaded());

  Future<void> continueWithFacebook(BuildContext context) async {
    if (state is OAuthLoading) return;
    emit(const OAuthLoading());
    final result = await repository.continueWithFacebook();
    result.match(
      (apiError) {
        logger.e('Login failed: ${apiError.message}');
        emit(OAuthError(apiError.message!));
      },
      (response) async {
        logger.i('Login successfully: ${response.accessToken}');
        await UserDataUtil.initUser(response);
        UserDataUtil.refreshData();
        emit(OAuthSuccess(
            "Successfully connected to Facebook account! Redirecting...",
            response));
      },
    );
  }

  Future<void> continueWithGoogle(BuildContext context) async {
    if (state is OAuthLoading) return;
    emit(const OAuthLoading());
    final result = await repository.continueWithGoogle();
    result.match(
      (apiError) {
        logger.e('Login failed: ${apiError.message}');
        emit(OAuthError(apiError.message!));
      },
      (response) async {
        logger.i('Login successfully: ${response.accessToken}');
        await UserDataUtil.initUser(response);
        UserDataUtil.refreshData();
        emit(OAuthSuccess(
            "Successfully connected to Google account! Redirecting...",
            response));
      },
    );
  }
}

abstract class OAuthState {
  const OAuthState();
}

class OAuthLoaded extends OAuthState {
  const OAuthLoaded() : super();
}

class OAuthLoading extends OAuthState {
  const OAuthLoading() : super();
}

class OAuthSuccess extends OAuthState {
  final String message;
  final LoginResponse response;
  const OAuthSuccess(this.message, this.response) : super();
}

class OAuthError extends OAuthState {
  final String message;
  const OAuthError(this.message) : super();
}
