import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/auth/data/login_request.dart';
import 'package:taste_tube/auth/data/login_response.dart';
import 'package:taste_tube/auth/data/register_request.dart';
import 'package:taste_tube/auth/data/register_response.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/storage.dart';

class AuthRepository {
  final SecureStorage secureStorage;
  final Dio http;

  AuthRepository({required this.secureStorage, required this.http});

  Future<Either<ApiError, RegisterResponse>> register(
      RegisterRequest request) async {
    try {
      final response = await http.post(
        Api.registerApi,
        data: request.toJson(),
      );
      final registerResponse = RegisterResponse.fromJson(response.data);
      return Right(registerResponse);
    } on DioException catch (e) {
      final apiError =
          ApiError.fromJson(e.response!.statusCode!, e.response?.data);
      return Left(apiError);
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Api.loginApi,
        data: request.toJson(),
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      await secureStorage.setRefreshToken(jwtFromHeader(response.headers));
      return Right(loginResponse);
    } on DioException catch (e) {
      final apiError =
          ApiError.fromJson(e.response!.statusCode!, e.response?.data);
      return Left(apiError);
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  String? jwtFromHeader(Headers headers) {
    final setCookieHeader = headers['set-cookie']?[0];
    if (setCookieHeader == null || setCookieHeader.length <= 4) {
      return null;
    } else {
      return setCookieHeader.substring(4, setCookieHeader.indexOf(';'));
    }
  }
}
