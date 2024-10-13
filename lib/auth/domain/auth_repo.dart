import 'dart:convert';
import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/auth/data/login_request.dart';
import 'package:taste_tube/auth/data/login_response.dart';
import 'package:taste_tube/auth/data/register_request.dart';
import 'package:taste_tube/auth/data/register_response.dart';
import 'package:taste_tube/common/http.dart';
import 'package:taste_tube/storage.dart';

class AuthRepository {
  final SecureStorage secureStorage;

  AuthRepository({required this.secureStorage});

  Future<Either<ApiError, RegisterResponse>> register(
      RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(Api.registerApi),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode < 300) {
        final json = jsonDecode(response.body);
        final registerResponse = RegisterResponse.fromJson(json);
        return Right(registerResponse);
      } else {
        final json = jsonDecode(response.body);
        final apiError = ApiError.fromJson(response.statusCode, json);
        return Left(apiError);
      }
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(Api.loginApi),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode < 300) {
        final json = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(json);
        await secureStorage.setRefreshToken(jwtFromHeader(response));
        return Right(loginResponse);
      } else {
        final json = jsonDecode(response.body);
        final apiError = ApiError.fromJson(response.statusCode, json);
        return Left(apiError);
      }
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  String? jwtFromHeader(Response response) {
    final setCookieHeader = response.headers['set-cookie'];
    if (setCookieHeader == null || setCookieHeader.length <= 4) {
      return null;
    } else {
      return setCookieHeader.substring(4);
    }
  }
}
