import 'package:taste_tube/global_data/user/user.dart';

abstract class UserManagementState {
  const UserManagementState();
}

class UserManagementInitial extends UserManagementState {}

class UserManagementLoading extends UserManagementState {
  final bool isFirstFetch;

  const UserManagementLoading({this.isFirstFetch = false});
}

class UserManagementLoaded extends UserManagementState {
  final List<User> users;
  final int totalDocs;
  final int limit;
  final bool hasPrevPage;
  final bool hasNextPage;
  final int page;
  final int totalPages;
  final int? prevPage;
  final int? nextPage;
  final String? searchQuery;
  final String? roleFilter;
  final String? statusFilter;

  const UserManagementLoaded({
    required this.users,
    required this.totalDocs,
    required this.limit,
    required this.hasPrevPage,
    required this.hasNextPage,
    required this.page,
    required this.totalPages,
    this.prevPage,
    this.nextPage,
    this.searchQuery,
    this.roleFilter,
    this.statusFilter,
  });

  UserManagementLoaded copyWith({
    List<User>? users,
    int? totalDocs,
    int? limit,
    bool? hasPrevPage,
    bool? hasNextPage,
    int? page,
    int? totalPages,
    int? prevPage,
    int? nextPage,
    String? searchQuery,
    String? roleFilter,
    String? statusFilter,
  }) {
    return UserManagementLoaded(
      users: users ?? this.users,
      totalDocs: totalDocs ?? this.totalDocs,
      limit: limit ?? this.limit,
      hasPrevPage: hasPrevPage ?? this.hasPrevPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      prevPage: prevPage ?? this.prevPage,
      nextPage: nextPage ?? this.nextPage,
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: roleFilter ?? this.roleFilter,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class UserManagementError extends UserManagementState {
  final String message;

  const UserManagementError(this.message);
}
