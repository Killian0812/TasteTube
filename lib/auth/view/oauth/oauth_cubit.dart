import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/auth/domain/auth_repo.dart';
import 'package:taste_tube/auth/view/register_page.ext.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/global_bloc/auth/bloc.dart';
import 'package:taste_tube/injection.dart';

class OAuthCubit extends Cubit<OAuthState> {
  final AuthRepository repository;
  final Logger logger;

  OAuthCubit()
      : repository = getIt<AuthRepository>(),
        logger = getIt<Logger>(),
        super(OAuthState());

  Future<void> continueWithFacebook(BuildContext context) async {
    if (state.isLoading) return;
    final result = await repository.continueWithFacebook();
    result.match(
      (apiError) {
        ToastService.showToast(context, apiError.message!,
            apiError.statusCode < 500 ? ToastType.warning : ToastType.error,
            duration: const Duration(seconds: 4));
        logger.e('Login failed: ${apiError.message}');
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        ToastService.showToast(
            context,
            "Successfully connected to Facebook account! Redirecting...",
            ToastType.success,
            duration: const Duration(seconds: 4));
        context.read<AuthBloc>().add(LoginEvent(AuthData(
              accessToken: response.accessToken,
              email: response.email,
              username: response.username,
              image: response.image,
              userId: response.userId,
              role: response.role,
            )));
        if (response.role.isNotEmpty) {
          if (response.role == 'RESTAURANT') {
            context.goNamed('profile',
                pathParameters: {'userId': response.userId});
          } else {
            context.go('/home');
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AccountTypeSelectionPage.provider(response.userId)),
          );
        }
        logger.i('Login successfully: ${response.accessToken}');
      },
    );
  }

  Future<void> continueWithGoogle(BuildContext context) async {
    if (state.isLoading) return;
    final result = await repository.continueWithGoogle();
    result.match(
      (apiError) {
        ToastService.showToast(context, apiError.message!,
            apiError.statusCode < 500 ? ToastType.warning : ToastType.error,
            duration: const Duration(seconds: 4));
        logger.e('Login failed: ${apiError.message}');
        emit(state.copyWith(isLoading: false));
      },
      (response) {
        ToastService.showToast(
            context,
            "Successfully connected to Google account! Redirecting...",
            ToastType.success,
            duration: const Duration(seconds: 4));
        context.read<AuthBloc>().add(LoginEvent(AuthData(
              accessToken: response.accessToken,
              email: response.email,
              username: response.username,
              image: response.image,
              userId: response.userId,
              role: response.role,
            )));
        if (response.role.isNotEmpty) {
          if (response.role == 'RESTAURANT') {
            context.goNamed('profile',
                pathParameters: {'userId': response.userId});
          } else {
            context.go('/home');
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AccountTypeSelectionPage.provider(response.userId)),
          );
        }
        logger.i('Login successfully: ${response.accessToken}');
      },
    );
  }
}

class OAuthState {
  final bool isLoading;

  OAuthState({
    this.isLoading = false,
  });

  OAuthState copyWith({
    bool? isLoading,
  }) {
    return OAuthState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
