import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/user/user.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class ContentRepository {
  final Dio http;
  final Dio recommendedFeedHttp = Dio(
    BaseOptions(
      baseUrl: 'https://taste-tube-personalize.vercel.app',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  ContentRepository({required this.http});

  Future<Either<ApiError, List<Video>>> getFeeds({
    int limit = 3,
    int skip = 0,
  }) async {
    try {
      final response =
          await recommendedFeedHttp.get('/api/feed', queryParameters: {
        'user_id': UserDataUtil.getUserId(),
        'limit': limit,
        'skip': skip,
      });
      final videos = (response.data as List<dynamic>)
          .map((videoJson) => Video.fromJson(videoJson as Map<String, dynamic>))
          .toList();
      return Right(videos);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, List<Video>>> getFollowingFeeds() async {
    try {
      final response = await http.get(Api.followingFeedApi);
      final videos = (response.data['feeds'] as List<dynamic>)
          .map((videoJson) => Video.fromJson(videoJson as Map<String, dynamic>))
          .toList();
      return Right(videos);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, List<User>>> searchForUser(String keyword) async {
    try {
      final response = await http.get(Api.searchApi, queryParameters: {
        'keyword': keyword,
        'type': 'user',
      });
      final users = (response.data as List<dynamic>)
          .map((userJson) => User.fromJson(userJson as Map<String, dynamic>))
          .toList();
      return Right(users);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, List<Video>>> searchForVideo(String keyword) async {
    try {
      final response = await http.get(Api.searchApi, queryParameters: {
        'keyword': keyword,
        'type': 'video',
      });
      final videos = (response.data as List<dynamic>)
          .map((videoJson) => Video.fromJson(videoJson as Map<String, dynamic>))
          .toList();
      return Right(videos);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
