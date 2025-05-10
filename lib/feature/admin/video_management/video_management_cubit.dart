import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/feature/admin/video_management/video_management_state.dart';
import 'package:taste_tube/feature/watch/domain/video_repo.dart';

class VideoManagementCubit extends Cubit<VideoManagementState> {
  final VideoRepository videoRepository = getIt<VideoRepository>();
  static const int _limit = 10;

  VideoManagementCubit() : super(VideoManagementInitial());

  Future<void> fetchVideos({
    String? searchQuery,
    String? visibilityFilter,
    String? statusFilter,
    String? userIdFilter,
    int page = 1,
  }) async {
    emit(VideoManagementLoading(isFirstFetch: page == 1));

    final result = await videoRepository.getVideos(
      page: page,
      limit: _limit,
      visibility: visibilityFilter,
      status: statusFilter,
      search: searchQuery,
      userId: userIdFilter,
    );

    result.fold(
      (error) => emit(VideoManagementError(error.message!)),
      (response) {
        final newVideos = response.videos;

        emit(VideoManagementLoaded(
          videos: newVideos,
          totalDocs: response.totalDocs,
          limit: response.limit,
          hasPrevPage: response.hasPrevPage,
          hasNextPage: response.hasNextPage,
          page: response.page,
          totalPages: response.totalPages,
          prevPage: response.prevPage,
          nextPage: response.nextPage,
          searchQuery: searchQuery,
          visibilityFilter: visibilityFilter,
          statusFilter: statusFilter,
        ));
      },
    );
  }

  Future<void> updateVideoStatus(String videoId, String status) async {
    if (state is! VideoManagementLoaded) return;

    final currentState = state as VideoManagementLoaded;
    emit(VideoManagementLoading());

    final result = await videoRepository.updateVideoStatus(videoId, status);

    result.fold(
      (error) => emit(VideoManagementError(error.message!)),
      (updatedVideo) {
        final updatedVideos = currentState.videos.map((video) {
          if (video.id == videoId) {
            return updatedVideo;
          }
          return video;
        }).toList();

        emit(currentState.copyWith(videos: updatedVideos));
      },
    );
  }

  void resetFilters() {
    emit(VideoManagementInitial());
    fetchVideos();
  }
}
