import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/auth/data/login_request.dart';
import 'package:taste_tube/auth/data/login_response.dart';
import 'package:taste_tube/auth/data/register_request.dart';
import 'package:taste_tube/auth/data/register_response.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/storage.dart';

class AuthRepository {
  final SecureStorage secureStorage;
  final Dio http;
  final Logger logger = getIt();

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
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, String>> setRole(SetRoleRequest request) async {
    try {
      final response = await http.post(
        Api.setRoleApi,
        data: request.toJson(),
      );
      return Right(response.data?['message'] ?? "");
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
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
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<LoginResult?> continueWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      // final userData = await FacebookAuth.instance.getUserData();
      // send userData to BE
      return loginResult;
    } catch (e) {
      logger.e("Error getting Facebook auth", error: e);
      return null;
    }
  }

  Future<GoogleSignInAccount?> continueWithGoogle() async {
    final GoogleSignInAccount? googleUser =
        await getIt<GoogleSignIn>().signIn();
    // send googleUser to BE
    return googleUser;
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
