import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/home/domain/content_repo.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/core/injection.dart';

abstract class ContentState {
  final List<Video> videos;

  const ContentState(this.videos);
}

class ContentLoading extends ContentState {
  ContentLoading() : super([]);
}

class ContentLoaded extends ContentState {
  const ContentLoaded(super.videos);
}

class ContentError extends ContentState {
  final String message;

  const ContentError(super.videos, this.message);
}

String get currentPlayingVideoId =>
    getIt<ContentCubit>().currentPlayingVideoId.value;
set currentPlayingVideoId(String id) =>
    getIt<ContentCubit>().currentPlayingVideoId.value = id;

String? tempVideoId;

class ContentCubit extends Cubit<ContentState> {
  final ValueNotifier<String> currentPlayingVideoId =
      ValueNotifier<String>("none");
  final ContentRepository repository = getIt<ContentRepository>();

  ContentCubit() : super(ContentLoading());

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
  Future<void> getFeeds() async {
    try {
      final result = await repository.getFeeds();
      result.fold(
        (error) => emit(ContentError(
          [],
          error.message ?? 'Error fetching videos',
        )),
        (videos) {
          videos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          emit(
            ContentLoaded(videos),
          );
        },
      );
    } catch (e) {
      emit(ContentError([], e.toString()));
    }
  }
}
