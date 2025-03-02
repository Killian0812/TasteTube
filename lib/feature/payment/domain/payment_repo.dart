import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';

class PaymentRepository {
  final Dio http;

  PaymentRepository({required this.http});

  Future<fpdart.Either<ApiError, String>> getPaymentUrl(
      double amount, String currency) async {
    try {
      final response = await http.post(Api.getVnpayUrl, data: {
        'amount': amount,
        'currency': currency,
      });
      return fpdart.Right(response.data['url']);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }
}
