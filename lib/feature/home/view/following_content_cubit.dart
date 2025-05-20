import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/home/domain/content_repo.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/core/injection.dart';

abstract class FollowingContentState {
  final List<Video> videos;

  const FollowingContentState(this.videos);
}

class FollowingContentLoading extends FollowingContentState {
  FollowingContentLoading() : super([]);
}

class FollowingContentLoaded extends FollowingContentState {
  const FollowingContentLoaded(super.videos);
}

class FollowingContentError extends FollowingContentState {
  final String message;

  const FollowingContentError(super.videos, this.message);
}

String get currentPlayingVideoId =>
    getIt<FollowingContentCubit>().currentPlayingVideoId.value;
set currentPlayingVideoId(String id) =>
    getIt<FollowingContentCubit>().currentPlayingVideoId.value = id;

String? tempVideoId;

class FollowingContentCubit extends Cubit<FollowingContentState> {
  final ValueNotifier<String> currentPlayingVideoId =
      ValueNotifier<String>("none");
  final ContentRepository repository = getIt<ContentRepository>();

  FollowingContentCubit() : super(FollowingContentLoading());

  void pauseContent() {
    tempVideoId = currentPlayingVideoId.value;
    currentPlayingVideoId.value = "none";
  }

  void resumeContent() {
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
  Future<void> getFollowingContentFeeds() async {
    try {
      final result = await repository.getFollowingFeeds();
      result.fold(
        (error) => emit(FollowingContentError(
          [],
          error.message ?? 'Error fetching videos',
        )),
        (videos) {
          videos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          emit(
            FollowingContentLoaded(videos),
          );
        },
      );
    } catch (e) {
      emit(FollowingContentError([], e.toString()));
    }
  }
}
