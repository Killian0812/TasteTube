import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/watch/video.dart';

class ContentRepository {
  final Dio http;

  ContentRepository({required this.http});

  Future<Either<ApiError, List<Video>>> getFeeds() async {
    try {
      final response = await http.get(Api.feedApi);
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
