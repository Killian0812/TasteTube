import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/global_data/watch/comment.dart';
import 'package:taste_tube/global_data/watch/interaction.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/feature/watch/domain/single_video_repo.dart';
import 'package:taste_tube/core/injection.dart';

abstract class SingleVideoState {
  final List<Comment> comments;
  final Interaction interaction;
  final Comment? replyingComment;

  SingleVideoState(
    this.comments,
    this.interaction,
  ) : replyingComment = null;

  SingleVideoState.withReplyingComment(
    this.comments,
    this.interaction,
    this.replyingComment,
  );
}

class SingleVideoInitial extends SingleVideoState {
  SingleVideoInitial(
    super.comments,
    super.interaction,
  );
}

class SingleVideoLoading extends SingleVideoState {
  SingleVideoLoading(
    super.comments,
    super.interaction,
  );
}

class SingleVideoSuccess extends SingleVideoState {
  final String message;

  SingleVideoSuccess(
    super.comments,
    super.interaction,
    this.message,
  );
}

class SingleVideoLoaded extends SingleVideoState {
  SingleVideoLoaded(
    super.comments,
    super.interaction,
    super.replyingComment,
  ) : super.withReplyingComment();
}

class SingleVideoError extends SingleVideoState {
  final String message;

  SingleVideoError(
    super.comments,
    super.interaction,
    this.message,
  );
}

class DeleteVideoSuccess extends SingleVideoState {
  DeleteVideoSuccess(
    super.comments,
    super.interaction,
  );
}

class DeleteVideoError extends SingleVideoState {
  final String message;

  DeleteVideoError(
    super.comments,
    super.interaction,
    this.message,
  );
}

class SingleVideoCubit extends Cubit<SingleVideoState> {
  final Video video;
  final SingleVideoRepository singleVideoRepo;

  SingleVideoCubit(this.video)
      : singleVideoRepo = getIt<SingleVideoRepository>(),
        super(SingleVideoLoading(
            [],
            Interaction(
              videoId: video.id,
              totalLikes: 0,
              totalViews: 0,
              totalShares: 0,
              totalBookmarked: 0,
              userLiked: false,
            )));

  Future<void> fetchDependency() async {
    try {
      final result = await singleVideoRepo.getVideoInfo(video.id);
      result.fold(
        (error) => emit(SingleVideoError(state.comments, state.interaction,
            error.message ?? 'Error fetching video')),
        (interaction) {
          emit(SingleVideoLoaded(state.comments, interaction, null));
        },
      );
    } catch (e) {
      emit(SingleVideoError(state.comments, state.interaction, e.toString()));
    }
  }

  Future<void> fetchComments() async {
    try {
      final result = await singleVideoRepo.getComments(video.id);
      result.fold(
        (error) => emit(SingleVideoError(state.comments, state.interaction,
            error.message ?? 'Error fetching video')),
        (comments) {
          emit(SingleVideoLoaded(comments, state.interaction, null));
        },
      );
    } catch (e) {
      emit(SingleVideoError(state.comments, state.interaction, e.toString()));
    }
  }

  Future<void> setReplyToComment(Comment? comment) async {
    emit(SingleVideoLoaded(state.comments, state.interaction, comment));
  }

  Future<void> postComment(String text) async {
    try {
      final result = await singleVideoRepo.postComment(
        video.id,
        text,
        replyingTo: state.replyingComment,
      );
      result.fold(
        (error) => emit(SingleVideoError(state.comments, state.interaction,
            error.message ?? 'Error commenting video')),
        (comment) {
          if (state.replyingComment == null) {
            emit(SingleVideoLoaded(
                state.comments..add(comment), state.interaction, null));
          }
          final parentCommentIndex = state.comments.indexWhere(
            (c) => c.id == state.replyingComment!.id,
          );
          if (parentCommentIndex != -1) {
            final parentComment = state.comments[parentCommentIndex];
            parentComment.replies.add(comment);
            emit(SingleVideoLoaded(
                List.from(state.comments), state.interaction, null));
          }
        },
      );
    } catch (e) {
      emit(SingleVideoError(state.comments, state.interaction, e.toString()));
    }
  }

  Future<void> deleteComment(Comment comment) async {
    try {
      final result = await singleVideoRepo.deleteComment(video.id, comment.id);
      result.fold(
        (error) => emit(SingleVideoError(state.comments, state.interaction,
            error.message ?? 'Error deleting comment')),
        (success) {
          if (comment.parentCommentId == null) {
            emit(SingleVideoLoaded(
              state.comments
                ..removeWhere(
                  (c) => c.id == comment.id,
                ),
              state.interaction,
              null,
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
            emit(SingleVideoLoaded(
                List.from(state.comments), state.interaction, null));
          }
        },
      );
    } catch (e) {
      emit(SingleVideoError(state.comments, state.interaction, e.toString()));
    }
  }

  Future<void> deleteVideo(Video video) async {
    try {
      final result = await singleVideoRepo.deleteVideo(video.id);
      result.fold(
          (error) => emit(DeleteVideoError(state.comments, state.interaction,
              error.message ?? 'Error deleting video')), (success) {
        emit(DeleteVideoSuccess(state.comments, state.interaction));
      });
    } catch (e) {
      emit(DeleteVideoError(state.comments, state.interaction, e.toString()));
    }
  }

  Future<void> likeVideo() async {
    try {
      final result = await singleVideoRepo.likeVideo(video.id);
      result.fold(
        (error) => emit(SingleVideoError(state.comments, state.interaction,
            error.message ?? 'Error liking video')),
        (success) {
          if (state.interaction.userLiked) return;
          emit(SingleVideoLoaded(
            state.comments,
            state.interaction.copyWith(
                userLiked: true, totalLikes: state.interaction.totalLikes + 1),
            null,
          ));
        },
      );
    } catch (e) {
      emit(SingleVideoError(state.comments, state.interaction, e.toString()));
    }
  }

  Future<void> unlikeVideo() async {
    try {
      final result = await singleVideoRepo.unlikeVideo(video.id);
      result.fold(
        (error) => emit(SingleVideoError(state.comments, state.interaction,
            error.message ?? 'Error unliking video')),
        (success) {
          if (!state.interaction.userLiked) return;
          emit(SingleVideoLoaded(
            state.comments,
            state.interaction.copyWith(
                userLiked: false, totalLikes: state.interaction.totalLikes - 1),
            null,
          ));
        },
      );
    } catch (e) {
      emit(SingleVideoError(state.comments, state.interaction, e.toString()));
    }
  }

  Future<void> shareVideo() async {
    try {
      final result = await singleVideoRepo.shareVideo(video.id);
      result.fold(
        (error) => emit(SingleVideoError(state.comments, state.interaction,
            error.message ?? 'Error sharing video')),
        (success) {},
      );
    } catch (e) {
      emit(SingleVideoError(state.comments, state.interaction, e.toString()));
    }
  }
}
