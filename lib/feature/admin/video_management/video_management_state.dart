import 'package:taste_tube/global_data/watch/video.dart';

abstract class VideoManagementState {
  const VideoManagementState();
}

class VideoManagementInitial extends VideoManagementState {}

class VideoManagementLoading extends VideoManagementState {
  final bool isFirstFetch;

  const VideoManagementLoading({this.isFirstFetch = false});
}

class VideoManagementLoaded extends VideoManagementState {
  final List<Video> videos;
  final int totalDocs;
  final int limit;
  final bool hasPrevPage;
  final bool hasNextPage;
  final int page;
  final int totalPages;
  final int? prevPage;
  final int? nextPage;
  final String? searchQuery;
  final String? visibilityFilter;
  final String? statusFilter;
  final String? userIdFilter;

  const VideoManagementLoaded({
    required this.videos,
    required this.totalDocs,
    required this.limit,
    required this.hasPrevPage,
    required this.hasNextPage,
    required this.page,
    required this.totalPages,
    this.prevPage,
    this.nextPage,
    this.searchQuery,
    this.visibilityFilter,
    this.statusFilter,
    this.userIdFilter,
  });

  VideoManagementLoaded copyWith({
    List<Video>? videos,
    int? totalDocs,
    int? limit,
    bool? hasPrevPage,
    bool? hasNextPage,
    int? page,
    int? totalPages,
    int? prevPage,
    int? nextPage,
    String? searchQuery,
    String? visibilityFilter,
    String? statusFilter,
    String? userIdFilter,
  }) {
    return VideoManagementLoaded(
      videos: videos ?? this.videos,
      totalDocs: totalDocs ?? this.totalDocs,
      limit: limit ?? this.limit,
      hasPrevPage: hasPrevPage ?? this.hasPrevPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      prevPage: prevPage ?? this.prevPage,
      nextPage: nextPage ?? this.nextPage,
      searchQuery: searchQuery ?? this.searchQuery,
      visibilityFilter: visibilityFilter ?? this.visibilityFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      userIdFilter: userIdFilter ?? this.userIdFilter,
    );
  }
}

class VideoManagementError extends VideoManagementState {
  final String message;

  const VideoManagementError(this.message);
}
