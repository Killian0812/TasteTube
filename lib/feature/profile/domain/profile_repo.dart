import 'dart:async';
import 'dart:io';

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

  Future<Either<ApiError, User>> updateInfo(
    String userId, {
    String? username,
    String? email,
    String? phone,
    String? bio,
    File? imageFile,
  }) async {
    try {
      final formData = FormData();

      // Add user information to the FormData
      if (username != null) {
        formData.fields.add(MapEntry('username', username));
      }
      if (email != null) {
        formData.fields.add(MapEntry('email', email));
      }
      if (phone != null) {
        formData.fields.add(MapEntry('phone', phone));
      }
      if (bio != null) {
        formData.fields.add(MapEntry('bio', bio));
      }
      if (imageFile != null) {
        formData.files.add(MapEntry(
          'image', // The key should match your API's expected key for the image
          await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
        ));
      }

      final response = await http.post(
        Api.userApi.replaceFirst(':userId', userId),
        options: Options(headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json'
        }),
        data: formData,
      );

      final userResponse = User.fromJson(response.data);
      return Right(userResponse);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}