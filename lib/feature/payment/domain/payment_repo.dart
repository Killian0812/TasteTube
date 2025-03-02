import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';

class Payment {
  final String url;
  final String pid;

  const Payment(this.url, this.pid);
}

class PaymentRepository {
  final Dio http;

  PaymentRepository({required this.http});

  Future<fpdart.Either<ApiError, Payment>> getPaymentUrl(
      double amount, String currency) async {
    try {
      final response = await http.post(Api.getVnpayUrl, data: {
        'amount': amount,
        'currency': currency,
      });
      return fpdart.Right(Payment(response.data['url'], response.data['pid']));
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }
}
