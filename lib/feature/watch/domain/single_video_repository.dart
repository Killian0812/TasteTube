import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/global_data/watch/comment.dart';

class SingleVideoRepository {
  final Dio http;

  SingleVideoRepository({required this.http});

  Future<Either<ApiError, Video>> getVideoInfo(String videoId) async {
    try {
      final response =
          await http.get(Api.videoApi.replaceFirst(':videoId', videoId));
      final video = Video.fromJson(response.data);
      return Right(video);
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
      await http.delete(Api.videoApi.replaceFirst(':videoId', videoId));
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
}
