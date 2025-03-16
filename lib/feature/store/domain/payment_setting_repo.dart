import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/store/data/payment_card.dart';

class PaymentSettingRepository {
  final Dio http;

  PaymentSettingRepository({required this.http});

  Future<fpdart.Either<ApiError, String>> changeCurrency(
      String newCurrency) async {
    try {
      final response = await http.put(
        Api.changeCurrency,
        data: {'currency': newCurrency},
      );
      final String updatedCurrency = response.data['updatedCurrency'] as String;
      return fpdart.Right(updatedCurrency);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }

  Future<fpdart.Either<ApiError, List<PaymentCard>>> getCards() async {
    try {
      final response = await http.get(Api.getCards);
      final List<dynamic> data = response.data;
      final cards = data.map((json) => PaymentCard.fromJson(json)).toList();
      return fpdart.Right(cards);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }

  Future<fpdart.Either<ApiError, PaymentCard>> addCard({
    required String type,
    required String cardNumber,
    required String holderName,
    required String expiryDate,
  }) async {
    try {
      final response = await http.post(
        Api.addCard,
        data: {
          'type': type,
          'cardNumber': cardNumber,
          'holderName': holderName,
          'expiryDate': expiryDate,
        },
      );
      final card = PaymentCard.fromJson(response.data);
      return fpdart.Right(card);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }

  Future<fpdart.Either<ApiError, PaymentCard>> setDefaultCard(
      String cardId) async {
    try {
      final response =
          await http.put(Api.setDefaultCard.replaceFirst(':cardId', cardId));
      final card = PaymentCard.fromJson(response.data);
      return fpdart.Right(card);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }

  Future<fpdart.Either<ApiError, PaymentCard>> removeCard(String cardId) async {
    try {
      final response =
          await http.delete(Api.removeCard.replaceFirst(':cardId', cardId));
      final card = PaymentCard.fromJson(response.data);
      return fpdart.Right(card);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }
}
