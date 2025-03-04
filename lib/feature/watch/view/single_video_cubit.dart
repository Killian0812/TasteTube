import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/global_data/watch/comment.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/feature/watch/domain/single_video_repo.dart';
import 'package:taste_tube/injection.dart';

abstract class SingleVideoState {
  final Video video;
  final List<Comment> comments;

  SingleVideoState(this.video, this.comments);
}

class SingleVideoInitial extends SingleVideoState {
  SingleVideoInitial(super.video, super.comments);
}

class SingleVideoLoading extends SingleVideoState {
  SingleVideoLoading(super.video, super.comments);
}

class SingleVideoSuccess extends SingleVideoState {
  final String message;

  SingleVideoSuccess(super.video, super.comments, this.message);
}

class SingleVideoLoaded extends SingleVideoState {
  SingleVideoLoaded(super.video, super.comments);
}

class SingleVideoError extends SingleVideoState {
  final String message;

  SingleVideoError(super.video, super.comments, this.message);
}

class DeleteVideoSuccess extends SingleVideoState {
  DeleteVideoSuccess(super.video, super.comments);
}

class DeleteVideoError extends SingleVideoState {
  final String message;

  DeleteVideoError(super.video, super.comments, this.message);
}

class SingleVideoCubit extends Cubit<SingleVideoState> {
  final Video video;
  final SingleVideoRepository singleVideoRepo;

  SingleVideoCubit(this.video)
      : singleVideoRepo = getIt<SingleVideoRepository>(),
        super(SingleVideoInitial(video, []));

  Future<void> fetchDependency() async {
    try {
      emit(SingleVideoLoading(state.video, state.comments));
      final result = await singleVideoRepo.getVideoInfo(video.id);
      result.fold(
        (error) => emit(SingleVideoError(state.video, state.comments,
            error.message ?? 'Error fetching video')),
        (video) {
          emit(SingleVideoLoaded(video, state.comments));
        },
      );
    } catch (e) {
      emit(SingleVideoError(state.video, state.comments, e.toString()));
    }
  }

  Future<void> fetchComments() async {
    try {
      final result = await singleVideoRepo.getComments(video.id);
      result.fold(
        (error) => emit(SingleVideoError(state.video, state.comments,
            error.message ?? 'Error fetching video')),
        (comments) {
          emit(SingleVideoLoaded(state.video, comments));
        },
      );
    } catch (e) {
      emit(SingleVideoError(state.video, state.comments, e.toString()));
    }
  }

  Future<void> postComment(String text, {Comment? replyingTo}) async {
    try {
      final result = await singleVideoRepo.postComment(
        state.video.id,
        text,
        replyingTo: replyingTo,
      );
      result.fold(
        (error) => emit(SingleVideoError(state.video, state.comments,
            error.message ?? 'Error commenting video')),
        (comment) {
          state.video.comments++;
          if (replyingTo == null) {
            emit(SingleVideoLoaded(state.video, state.comments..add(comment)));
          }
          final parentCommentIndex = state.comments.indexWhere(
            (c) => c.id == replyingTo!.id,
          );
          if (parentCommentIndex != -1) {
            final parentComment = state.comments[parentCommentIndex];
            parentComment.replies.add(comment);
            emit(SingleVideoLoaded(state.video, List.from(state.comments)));
          }
        },
      );
    } catch (e) {
      emit(SingleVideoError(state.video, state.comments, e.toString()));
    }
  }

  Future<void> deleteComment(Comment comment) async {
    try {
      final result =
          await singleVideoRepo.deleteComment(state.video.id, comment.id);
      result.fold(
        (error) => emit(SingleVideoError(state.video, state.comments,
            error.message ?? 'Error deleting comment')),
        (success) {
          state.video.comments--;
          if (comment.parentCommentId == null) {
            emit(SingleVideoLoaded(
              state.video,
              state.comments
                ..removeWhere(
                  (c) => c.id == comment.id,
                ),
            ));
          }
          final parentCommentIndex = state.comments.indexWhere(
            (c) => c.id == comment.parentCommentId,
          );
          if (parentCommentIndex != -1) {
            final parentComment = state.comments[parentCommentIndex];
            parentComment.replies.removeWhere(
              (c) => c.id == comment.id,
            );
            emit(SingleVideoLoaded(state.video, List.from(state.comments)));
          }
        },
      );
    } catch (e) {
      emit(SingleVideoError(state.video, state.comments, e.toString()));
    }
  }

  Future<void> deleteVideo(Video video) async {
    try {
      final result = await singleVideoRepo.deleteVideo(state.video.id);
      result.fold(
          (error) => emit(DeleteVideoError(state.video, state.comments,
              error.message ?? 'Error deleting video')), (success) {
        emit(DeleteVideoSuccess(state.video, state.comments));
      });
    } catch (e) {
      emit(DeleteVideoError(state.video, state.comments, e.toString()));
    }
  }

  Future<void> likeVideo() async {
    try {
      final result = await singleVideoRepo.likeVideo(state.video.id);
      result.fold(
        (error) => emit(SingleVideoError(state.video, state.comments,
            error.message ?? 'Error liking video')),
        (success) {
          final updatedVideo = state.video;
          if (!updatedVideo.userLiked) {
            updatedVideo.userLiked = true;
            updatedVideo.likes++;
          }
          emit(SingleVideoLoaded(
            updatedVideo,
            state.comments,
          ));
        },
      );
    } catch (e) {
      emit(SingleVideoError(state.video, state.comments, e.toString()));
    }
  }

  Future<void> unlikeVideo() async {
    try {
      final result = await singleVideoRepo.unlikeVideo(state.video.id);
      result.fold(
        (error) => emit(SingleVideoError(state.video, state.comments,
            error.message ?? 'Error unliking video')),
        (success) {
          final updatedVideo = state.video;
          if (updatedVideo.userLiked) {
            updatedVideo.userLiked = false;
            updatedVideo.likes--;
          }
          emit(SingleVideoLoaded(
            updatedVideo,
            state.comments,
          ));
        },
      );
    } catch (e) {
      emit(SingleVideoError(state.video, state.comments, e.toString()));
    }
  }
}
