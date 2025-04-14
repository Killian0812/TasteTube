import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/auth/data/login_request.dart';
import 'package:taste_tube/auth/data/register_request.dart';
import 'package:taste_tube/auth/data/register_response.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/core/storage.dart';

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

  Future<Either<ApiError, AuthData>> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Api.loginApi,
        data: request.toJson(),
      );
      final authData = AuthData.fromJson({
        ...(response.data as Map<String, dynamic>),
        "refreshToken": jwtFromHeader(response.headers) ??
            response.data['refreshToken'] ??
            ''
      });
      return Right(authData);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, AuthData>> continueWithFacebook() async {
    try {
      await FacebookAuth.instance.login();
      final userData = await FacebookAuth.instance.getUserData();
      if (userData["error"] != null) {
        return Left(ApiError(500, userData["error"]["message"]));
      }
      final response = await http.post(
        Api.facebookAuthApi,
        data: userData,
      );
      final authData = AuthData.fromJson({
        ...(response.data as Map<String, dynamic>),
        "refreshToken": jwtFromHeader(response.headers) ??
            response.data['refreshToken'] ??
            ''
      });
      return Right(authData);
    } on DioException catch (e) {
      await FacebookAuth.instance.logOut();
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      await FacebookAuth.instance.logOut();
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, AuthData>> continueWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await getIt<GoogleSignIn>().signIn();
      if (googleUser == null) {
        return const Left(ApiError(500, 'No google user found'));
      }
      final response = await http.post(
        Api.googleAuthApi,
        data: {
          'email': googleUser.email,
          'name': googleUser.displayName,
          'picture': googleUser.photoUrl,
        },
      );
      final authData = AuthData.fromJson({
        ...(response.data as Map<String, dynamic>),
        "refreshToken": jwtFromHeader(response.headers) ??
            response.data['refreshToken'] ??
            ''
      });
      return Right(authData);
    } on DioException catch (e) {
      await getIt<GoogleSignIn>().signOut();
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      await getIt<GoogleSignIn>().signOut();
      return Left(ApiError(500, e.toString()));
    }
  }

  String? jwtFromHeader(Headers headers) {
    final setCookieHeader = headers['set-cookie']?[0];
    final xAuthTokenHeader = headers['x-auth-token']?[0];
    if (xAuthTokenHeader != null && xAuthTokenHeader.isNotEmpty) {
      return xAuthTokenHeader;
    }
    if (setCookieHeader == null || setCookieHeader.length <= 4) {
      return null;
    } else {
      return setCookieHeader.substring(4, setCookieHeader.indexOf(';'));
    }
  }
}
