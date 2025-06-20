import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/update_video/data/update_video_request.dart';
import 'package:taste_tube/global_data/watch/interaction.dart';
import 'package:taste_tube/global_data/watch/comment.dart';
import 'package:taste_tube/global_data/watch/video.dart';

class VideoRepository {
  final Dio http;

  VideoRepository({required this.http});

  Future<Either<ApiError, Video>> getVideo(String videoId) async {
    try {
      final response =
          await http.get(Api.singleVideoApi.replaceFirst(':videoId', videoId));
      final video = Video.fromJson(response.data);
      return Right(video);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, Video>> updateVideo(
    String videoId,
    UpdateVideoRequest request,
  ) async {
    try {
      final response = await http.put(
        Api.singleVideoApi.replaceFirst(':videoId', videoId),
        data: request.toJson(),
      );
      final video = Video.fromJson(response.data['video']);
      return Right(video);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, Interaction>> getVideoInteraction(
      String videoId) async {
    try {
      final response = await http
          .get(Api.videoInteractionApi.replaceFirst(':videoId', videoId));
      final interaction = Interaction.fromJson(response.data);
      return Right(interaction);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, List<Comment>>> getComments(String videoId) async {
    try {
      final response =
          await http.get(Api.videoCommentApi.replaceFirst(':videoId', videoId));
      final comments = (response.data as List<dynamic>)
          .map((comment) => Comment.fromJson(comment as Map<String, dynamic>))
          .toList();
      return Right(comments);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, Comment>> postComment(
    String videoId,
    String text, {
    Comment? replyingTo,
  }) async {
    try {
      final response = await http.post(
        Api.videoCommentApi.replaceFirst(':videoId', videoId),
        data: {
          'text': text,
          if (replyingTo != null) 'parentCommentId': replyingTo.id
        },
      );
      final comment = Comment.fromJson(response.data);
      return Right(comment);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, bool>> deleteComment(
      String videoId, String commentId) async {
    try {
      await http.delete(Api.videoCommentApi.replaceFirst(':videoId', videoId),
          data: {'commentId': commentId});
      return const Right(true);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, bool>> deleteVideo(String videoId) async {
    try {
      await http.delete(Api.singleVideoApi.replaceFirst(':videoId', videoId));
      return const Right(true);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, bool>> likeVideo(String videoId) async {
    try {
      await http.post(Api.videoLikeApi.replaceFirst(':videoId', videoId));
      return const Right(true);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, bool>> watchedVideo(
    String videoId,
    int watchTime,
  ) async {
    try {
      await http.post(
        Api.videoWatchedApi.replaceFirst(':videoId', videoId),
        data: {'watchTime': watchTime},
      );
      return const Right(true);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, bool>> unlikeVideo(String videoId) async {
    try {
      await http.delete(Api.videoUnlikeApi.replaceFirst(':videoId', videoId));
      return const Right(true);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, bool>> shareVideo(String videoId) async {
    try {
      await http.post(Api.videoShareApi.replaceFirst(':videoId', videoId));
      return const Right(true);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, VideoResponse>> getVideos({
    required int page,
    required int limit,
    String? visibility,
    String? status,
    String? search,
    String? userId,
  }) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (visibility != null) 'visibility': visibility,
        if (status != null) 'status': status,
        if (userId != null) 'userId': userId,
        if (search != null) 'search': search,
      };

      final response =
          await http.get(Api.videoApi, queryParameters: queryParameters);

      final videoResponse = VideoResponse.fromJson(response.data);
      return Right(videoResponse);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, Video>> updateVideoStatus(
      String videoId, String status) async {
    try {
      final response = await http.put(
        Api.videoStatusApi.replaceFirst(':videoId', videoId),
        data: {'status': status},
      );

      final updatedVideo = Video.fromJson(response.data);
      return Right(updatedVideo);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
