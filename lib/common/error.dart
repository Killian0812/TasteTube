import 'package:dio/dio.dart';

class ApiError {
  final int statusCode;
  final String? message;

  const ApiError(this.statusCode, [this.message]);

  ApiError.fromJson(this.statusCode, Map<String, dynamic> json)
      : message = json['message'] as String?;

  ApiError.fromDioException(DioException e)
      : statusCode = e.response?.statusCode ?? 500,
        message = e.response == null
            ? e.error.toString()
            : e.response?.data is Map
                ? e.response!.data['message']
                : e.response?.data as String?;
}
