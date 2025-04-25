import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/upload/data/upload_video_request.dart';

class UploadRepository {
  final Dio http;

  UploadRepository({required this.http});

  Future<Either<ApiError, String>> upload(
      XFile xfile, UploadVideoRequest request) async {
    try {
      MultipartFile multipartFile;
      if (kIsWeb) {
        final bytes = await xfile.readAsBytes();
        multipartFile = MultipartFile.fromBytes(bytes,
            filename: xfile.name, contentType: DioMediaType.parse('video/mp4'));
      } else {
        multipartFile = await MultipartFile.fromFile(xfile.path,
            contentType: DioMediaType.parse('video/mp4'));
      }

      final formData = FormData();
      formData.files.add(MapEntry('video', multipartFile));
      request.toJson().forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
      final response = await http.post(
        Api.videoApi,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
      );
      return Right(response.data?['message'] ?? "");
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
