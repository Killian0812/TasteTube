import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/feature/admin/user_management/user_management_state.dart';
import 'package:taste_tube/feature/profile/domain/user_repo.dart';

class UserManagementCubit extends Cubit<UserManagementState> {
  final UserRepository userRepository = getIt<UserRepository>();
  static const int _limit = 10;

  UserManagementCubit() : super(UserManagementInitial());

  Future<void> fetchUsers({
    String? searchQuery,
    String? roleFilter,
    String? statusFilter,
    int page = 1,
  }) async {
    emit(UserManagementLoading(isFirstFetch: page == 1));

    final result = await userRepository.getUsers(
      page: page,
      limit: _limit,
      role: roleFilter,
      status: statusFilter,
      search: searchQuery,
    );

    result.fold(
      (error) => emit(UserManagementError(error.message!)),
      (response) {
        final newUsers = response.users;

        emit(UserManagementLoaded(
          users: newUsers,
          totalDocs: response.totalDocs,
          limit: response.limit,
          hasPrevPage: response.hasPrevPage,
          hasNextPage: response.hasNextPage,
          page: response.page,
          totalPages: response.totalPages,
          prevPage: response.prevPage,
          nextPage: response.nextPage,
          searchQuery: searchQuery,
          roleFilter: roleFilter,
          statusFilter: statusFilter,
        ));
      },
    );
  }

  Future<void> updateUserStatus(String userId, String status) async {
    if (state is! UserManagementLoaded) return;

    final currentState = state as UserManagementLoaded;
    emit(UserManagementLoading());

    final result = await userRepository.updateUserStatus(userId, status);

    result.fold(
      (error) => emit(UserManagementError(error.message!)),
      (updatedUser) {
        final updatedUsers = currentState.users.map((user) {
          if (user.id == userId) {
            return updatedUser;
          }
          return user;
        }).toList();

        emit(currentState.copyWith(users: updatedUsers));
      },
    );
  }

  void resetFilters() {
    emit(UserManagementInitial());
    fetchUsers();
  }
}
