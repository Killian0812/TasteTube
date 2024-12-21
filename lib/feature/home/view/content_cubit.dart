import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/home/domain/content_repo.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/injection.dart';

abstract class ContentState {
  final List<Video> videos;

  const ContentState({required this.videos});
}

class ContentInitial extends ContentState {
  ContentInitial() : super(videos: []);
}

class ContentLoading extends ContentState {
  const ContentLoading(List<Video> videos) : super(videos: videos);
}

class ContentLoaded extends ContentState {
  const ContentLoaded(List<Video> videos) : super(videos: videos);
}

class ContentSuccess extends ContentState {
  final String success;

  const ContentSuccess(List<Video> videos, this.success)
      : super(videos: videos);
}

class ContentError extends ContentState {
  final String error;

  const ContentError(List<Video> videos, this.error) : super(videos: videos);
}

class ContentCubit extends Cubit<ContentState> {
  final ContentRepository repository = getIt<ContentRepository>();

  ContentCubit() : super(ContentInitial());

  Future<void> getFeeds() async {
    emit(ContentLoading(state.videos));
    try {
      final result = await repository.getFeeds();
      result.fold(
        (error) => emit(ContentError(
          state.videos,
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
      emit(ContentError(state.videos, e.toString()));
    }
  }
}
