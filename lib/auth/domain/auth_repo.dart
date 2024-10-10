import 'dart:convert';
import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:taste_tube/api.dart';
import 'package:taste_tube/auth/data/register_request.dart';
import 'package:taste_tube/auth/data/register_response.dart';
import 'package:taste_tube/common/http.dart';

class AuthRepository {
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
}
