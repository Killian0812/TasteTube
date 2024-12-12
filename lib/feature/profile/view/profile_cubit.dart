import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/global_data/user/user.dart';
import 'package:taste_tube/feature/profile/domain/profile_repo.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/global_bloc/auth/bloc.dart';
import 'package:taste_tube/injection.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserRepository repository;
  final String userId;
  bool isOwner = false;

  ProfileCubit(this.userId)
      : repository = getIt<UserRepository>(),
        super(ProfileLoading(null));

  Future<void> init(BuildContext context) async {
    isOwner = (context.read<AuthBloc>().state.data?.userId == userId);
    final either = await repository.getInfo(userId);
    either.match(
      (apiError) {
        emit(ProfileFailure(state.user, apiError.message!));
      },
      (user) async {
        final likedVideos = isOwner ? await getLikedVideos() : null;
        final reviews = await getReviews();
        emit(ProfileSuccess(
          user,
          likedVideos: likedVideos ?? [],
          reviews: reviews ?? [],
        ));
      },
    );
  }

  Future<List<Video>?> getLikedVideos() async {
    final either = await repository.getLikedVideos();
    return either.match(
      (apiError) => null,
      (videos) => videos,
    );
  }

  Future<List<Video>?> getReviews() async {
    final either = await repository.getReviews(userId);
    return either.match(
      (apiError) => null,
      (videos) => videos,
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
        emit(ProfileFailure(state.user, apiError.message!));
      },
      (user) {
        emit(ProfileSuccess(user));
      },
    );
  }

  Future<void> followUser(User user, String currentUserId) async {
    final success = await repository.followUser(userId);
    if (success) {
      user.followers.add(currentUserId);
      emit(ProfileSuccess(user));
    }
  }

  Future<void> unfollowUser(User user, String currentUserId) async {
    final success = await repository.unfollowUser(userId);
    if (success) {
      user.followers.removeWhere((e) => e == currentUserId);
      emit(ProfileSuccess(user));
    }
  }
}

abstract class ProfileState {
  final User? user;
  final List<Video> likedVideos;
  final List<Video> reviews;
  ProfileState(
    this.user, {
    this.likedVideos = const [],
    this.reviews = const [],
  });
}

class ProfileLoading extends ProfileState {
  ProfileLoading(super.user, {super.likedVideos, super.reviews});
}

class ProfileSuccess extends ProfileState {
  ProfileSuccess(super.user, {super.likedVideos, super.reviews});
}

class ProfileFailure extends ProfileState {
  final String message;

  ProfileFailure(super.user, this.message, {super.likedVideos, super.reviews});
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
