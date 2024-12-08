import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/product/data/product.dart';

class ShopRepository {
  final Dio http;

  ShopRepository({required this.http});

  Future<Either<ApiError, List<Product>>> getRecommendedProducts() async {
    try {
      final response = await http.get(Api.shopRecommendedApi);
      final List<dynamic> data = response.data;
      final products = data.map((json) => Product.fromJson(json)).toList();
      return Right(products);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, List<Product>>> searchProducts(String keyword) async {
    try {
      final response = await http.get(Api.shopSearchApi, queryParameters: {
        'keyword': keyword,
      });
      final List<dynamic> data = response.data;
      final products = data.map((json) => Product.fromJson(json)).toList();
      return Right(products);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
