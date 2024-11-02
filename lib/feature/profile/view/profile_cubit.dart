import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/profile/data/user.dart';
import 'package:taste_tube/feature/profile/domain/profile_repo.dart';
import 'package:taste_tube/global_bloc/auth/bloc.dart';
import 'package:taste_tube/injection.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserRepository repository;
  final String userId;
  bool isOwner = false;

  ProfileCubit(this.userId)
      : repository = getIt<UserRepository>(),
        super(ProfileLoading());

  Future<void> init(BuildContext context) async {
    isOwner = (context.read<AuthBloc>().state.data?.userId == userId);
    final either = await repository.getInfo(userId);
    either.match(
      (apiError) {
        emit(ProfileFailure(apiError.message!));
      },
      (user) {
        emit(ProfileSuccess(user: user));
      },
    );
  }

  Future<void> updateProfile({
    String? username,
    String? email,
    String? phone,
    String? bio,
    File? imageFile,
  }) async {
    final either = await repository.updateInfo(
      userId,
      bio: bio,
      email: email,
      phone: phone,
      username: username,
      imageFile: imageFile,
    );
    either.match(
      (apiError) {
        emit(ProfileFailure(apiError.message!));
      },
      (user) {
        emit(ProfileSuccess(user: user));
      },
    );
  }
}

abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final User user;

  ProfileSuccess({required this.user});
}

class ProfileFailure extends ProfileState {
  final String message;

  ProfileFailure(this.message);
}

class PasswordCubit extends Cubit<PasswordState> {
  final UserRepository repository;
  final String userId;
  bool isOwner = false;

  PasswordCubit(this.userId)
      : repository = getIt<UserRepository>(),
        super(PasswordLoading());

  Future<void> changePassword(
      String oldPassword, String newPassword, String matchPassword) async {
    final either = await repository.changePassword(
      userId,
      oldPassword,
      newPassword,
      matchPassword,
    );
    either.match(
      (apiError) {
        emit(ChangePasswordFailure(apiError.message!));
      },
      (msg) {
        emit(ChangePasswordSuccess(msg));
      },
    );
  }
}

abstract class PasswordState {}

class PasswordLoading extends PasswordState {}

class ChangePasswordFailure extends PasswordState {
  final String message;

  ChangePasswordFailure(this.message);
}

class ChangePasswordSuccess extends PasswordState {
  final String message;

  ChangePasswordSuccess(this.message);
}
