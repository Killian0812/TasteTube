import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/store/data/delivery_options.dart';

class DeliveryOptionRepository {
  final Dio http;

  DeliveryOptionRepository({required this.http});

  Future<Either<ApiError, DeliveryOption>> getDeliveryOptions() async {
    try {
      final response = await http.get(Api.deliveryOptionApi);
      final data = response.data;
      final options = DeliveryOption.fromJson(data);
      return Right(options);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, DeliveryOption>> updateDeliveryOptions(
    DeliveryOption options,
  ) async {
    try {
      final response = await http.put(
        Api.deliveryOptionApi,
        data: options.toJson(),
      );
      final updatedOptions = DeliveryOption.fromJson(response.data);
      return Right(updatedOptions);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
