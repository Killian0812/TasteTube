import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/home/domain/content_repo.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/core/injection.dart';

abstract class ReviewState {
  final List<Video> videos;

  const ReviewState(this.videos);
}

class ReviewLoading extends ReviewState {
  ReviewLoading() : super([]);
}

class ReviewLoaded extends ReviewState {
  const ReviewLoaded(super.videos);
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(super.videos, this.message);
}

String get currentPlayingVideoId =>
    getIt<ReviewCubit>().currentPlayingVideoId.value;
set currentPlayingVideoId(String id) =>
    getIt<ReviewCubit>().currentPlayingVideoId.value = id;

String? tempVideoId;

class ReviewCubit extends Cubit<ReviewState> {
  final ValueNotifier<String> currentPlayingVideoId =
      ValueNotifier<String>("none");
  final ContentRepository repository = getIt<ContentRepository>();

  ReviewCubit() : super(ReviewLoading());

  void pauseReview() {
    tempVideoId = currentPlayingVideoId.value;
    currentPlayingVideoId.value = "none";
  }

  void resumeReview() {
    if (tempVideoId == null) return;
    currentPlayingVideoId.value = tempVideoId!;
    tempVideoId = null;
  }

  @override
  Future<void> close() async {
    currentPlayingVideoId.dispose();
    super.close();
  }

  // TODO: Add paginate fetch on WatchPage page change
  Future<void> getReviewFeeds() async {
    try {
      final result = await repository.getReviewFeeds();
      result.fold(
        (error) => emit(ReviewError(
          [],
          error.message ?? 'Error fetching videos',
        )),
        (videos) {
          videos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          emit(
            ReviewLoaded(videos),
          );
        },
      );
    } catch (e) {
      emit(ReviewError([], e.toString()));
    }
  }
}
