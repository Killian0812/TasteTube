import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/inbox/data/channel_settings.dart';

class ChatChannelRepository {
  final Dio http;

  ChatChannelRepository({required this.http});

  Future<Either<ApiError, ChannelSettings>> getSettings(
      String channelId) async {
    try {
      final response = await http
          .get(Api.channelSettings.replaceFirst(":channelId", channelId));
      final settings =
          ChannelSettings.fromJson(response.data as Map<String, dynamic>);
      return Right(settings);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, ChannelSettings>> updateSettings(
    String channelId, {
    bool? autoResponse,
  }) async {
    try {
      final response = await http.post(
        Api.channelSettings.replaceFirst(":channelId", channelId),
        data: {
          "autoResponse": autoResponse,
        },
      );
      final settings =
          ChannelSettings.fromJson(response.data as Map<String, dynamic>);
      return Right(settings);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
