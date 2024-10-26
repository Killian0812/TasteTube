import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/profile/data/user.dart';
import 'package:taste_tube/feature/profile/domain/profile_repo.dart';
import 'package:taste_tube/injection.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserRepository repository;

  ProfileCubit()
      : repository = getIt<UserRepository>(),
        super(ProfileLoading());

  Future<void> init(String userId) async {
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
