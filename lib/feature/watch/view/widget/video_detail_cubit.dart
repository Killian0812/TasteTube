import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/feature/watch/domain/video_repo.dart';
import 'package:taste_tube/core/injection.dart';

abstract class VideoDetailState {
  const VideoDetailState();
}

class VideoDetailLoading extends VideoDetailState {
  const VideoDetailLoading();
}

class VideoDetailLoaded extends VideoDetailState {
  final Video video;
  VideoDetailLoaded(this.video);
}

class VideoDetailError extends VideoDetailState {
  final String message;
  VideoDetailError(this.message);
}

class VideoDetailCubit extends Cubit<VideoDetailState> {
  final String videoId;
  final VideoRepository repository;

  VideoDetailCubit(this.videoId)
      : repository = getIt<VideoRepository>(),
        super(VideoDetailLoading());

  Future<void> fetchDependency() async {
    try {
      final result = await repository.getVideo(videoId);
      result.fold(
        (error) =>
            emit(VideoDetailError(error.message ?? 'Error fetching video')),
        (video) {
          emit(VideoDetailLoaded(video));
        },
      );
    } catch (e) {
      emit(VideoDetailError(e.toString()));
    }
  }
}
