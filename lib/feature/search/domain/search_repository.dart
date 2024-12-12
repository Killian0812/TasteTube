import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/user/user.dart';

class SearchRepository {
  final Dio http;

  SearchRepository({required this.http});

  Future<Either<ApiError, List<User>>> searchForUser(String keyword) async {
    try {
      final response =
          await http.post(Api.searchApi, data: {'keyword': keyword});
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
}
