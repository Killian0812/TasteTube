import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/user/user.dart';
import 'package:taste_tube/global_data/watch/video.dart';

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

  Future<Either<ApiError, List<Video>>> getOwnedVideos(String userId) async {
    try {
      final response = await http
          .get(Api.ownedVideoApi, queryParameters: {'userId': userId});
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

  Future<Either<ApiError, List<Video>>> getLikedVideos() async {
    try {
      final response = await http.get(Api.likedVideoApi);
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

  Future<Either<ApiError, List<Video>>> getReviews(String targetUserId,
      {String? productId}) async {
    try {
      final response = await http.get(Api.reviewVideoApi, queryParameters: {
        'targetUserId': targetUserId,
        if (productId != null) 'productId': productId
      });
      final json = response.data as Map<String, dynamic>;
      final videos = (json['videos'] as List<dynamic>)
          .map((videoJson) => Video.fromJson(videoJson as Map<String, dynamic>))
          .toList();
      return Right(videos);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, String>> changePassword(String userId,
      String oldPassword, String newPassword, String matchPassword) async {
    try {
      final response = await http
          .put(Api.changePasswordApi.replaceFirst(':userId', userId), data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'matchPassword': matchPassword,
      });
      return Right(response.data['message'] ?? '');
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
    XFile? imageFile,
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
        if (kIsWeb) {
          formData.files.add(MapEntry(
            'image', // The key should match your API's expected key for the image
            MultipartFile.fromBytes(await imageFile.readAsBytes(),
                filename: imageFile.path.split('/').last),
          ));
        } else {
          formData.files.add(MapEntry(
            'image',
            await MultipartFile.fromFile(imageFile.path,
                filename: imageFile.path.split('/').last),
          ));
        }
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

  Future<bool> followUser(String userId) async {
    try {
      final response =
          await http.put(Api.followUserApi.replaceFirst(':userId', userId));
      final Map<String, dynamic> json = response.data;
      final code = json['code'] as int?;
      if (code == 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> unfollowUser(String userId) async {
    try {
      final response =
          await http.put(Api.unfollowUserApi.replaceFirst(':userId', userId));
      final Map<String, dynamic> json = response.data;
      final code = json['code'] as int?;
      if (code == 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Either<ApiError, PaginatedUserResponse>> getUsers({
    int page = 1,
    int limit = 10,
    String? role,
    String? status,
    String? search,
  }) async {
    try {
      final response = await http.get(
        Api.usersApi,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (role != null) 'role': role,
          if (status != null) 'status': status,
          if (search != null) 'search': search,
        },
      );
      final paginatedResponse = PaginatedUserResponse.fromJson(response.data);
      return Right(paginatedResponse);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, User>> updateUserStatus(
      String userId, String status) async {
    try {
      final response = await http.put(
        Api.userStatusApi.replaceFirst(':userId', userId),
        data: {'status': status},
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
