import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';

class VnPayPayment {
  final String url;
  final String pid;

  const VnPayPayment(this.url, this.pid);
}

class PaymentRepository {
  final Dio http;

  PaymentRepository({required this.http});

  Future<fpdart.Either<ApiError, VnPayPayment>> getPaymentUrl(
      double amount, String currency) async {
    try {
      final response = await http.post(Api.getVnpayUrl, data: {
        'amount': amount,
        'currency': currency,
      });
      return fpdart.Right(
          VnPayPayment(response.data['url'], response.data['pid']));
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }

  Future<fpdart.Either<ApiError, bool>> createCardPayment(
      double amount, String currency) async {
    try {
      await http.post(Api.createCardPayment, data: {
        'amount': amount,
        'currency': currency,
      });
      return fpdart.Right(true);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }

  Future<fpdart.Either<ApiError, bool>> confirmCardPayment(String otp) async {
    try {
      await http.post(Api.confirmPayment, data: {'otp': otp});
      return fpdart.Right(true);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }
}
