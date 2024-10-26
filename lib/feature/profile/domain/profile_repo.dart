import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/profile/data/user.dart';

class UserRepository {
  final Dio http;

  UserRepository({required this.http});

  Future<Either<ApiError, User>> getInfo(String userId) async {
    try {
      final response =
          await http.get(Api.userApi.replaceFirst(':userId', userId));
      final userResponse = User.fromJson(response.data);
      return Right(userResponse);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
