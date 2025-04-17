import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/discount/discount.dart';

class DiscountRepository {
  final Dio http;

  DiscountRepository({required this.http});

  Future<Either<ApiError, List<Discount>>> fetchDiscounts(String shopId) async {
    try {
      final response =
          await http.get(Api.discountByShopApi.replaceFirst(":shopId", shopId));
      final List<dynamic> data = response.data;
      final discounts = data.map((json) => Discount.fromJson(json)).toList();
      return Right(discounts);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, Discount>> createDiscount(Discount discount) async {
    try {
      final response = await http.post(
        Api.discountApi,
        data: discount.toJson(),
      );
      return Right(Discount.fromJson(response.data));
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, Discount>> updateDiscount(
      String discountId, Discount discount) async {
    try {
      final response = await http.put(
        Api.singleDiscountApi.replaceFirst(":id", discountId),
        data: discount.toJson(),
      );
      return Right(Discount.fromJson(response.data));
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, void>> deleteDiscount(String discountId) async {
    try {
      await http.delete(Api.singleDiscountApi.replaceFirst(":id", discountId));
      return const Right(null);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
