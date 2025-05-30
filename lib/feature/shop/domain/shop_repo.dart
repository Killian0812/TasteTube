import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/shop/data/shop_response.dart';
import 'package:taste_tube/global_data/product/product.dart';

class ShopRepository {
  final Dio http;

  ShopRepository({required this.http});

  Future<Either<ApiError, ShopResponse>> getRecommendedProducts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Api.shopRecommendedApi,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Right(ShopResponse.fromJson(data));
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, ShopResponse>> searchProducts(
    String keyword, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Api.shopSearchApi,
        queryParameters: {
          'keyword': keyword,
          'page': page,
          'limit': limit,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Right(ShopResponse.fromJson(data));
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, List<Product>>> getSingleShopProducts(
      String shopId) async {
    try {
      final response =
          await http.get(Api.singleShopApi.replaceFirst(':shopId', shopId));
      final List<dynamic> data = response.data;
      final products = data.map((json) => Product.fromJson(json)).toList();
      return Right(products);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, List<Product>>> searchSingleShopProducts(
      String shopId, String keyword) async {
    try {
      final response = await http.get(
          Api.singleShopSearchApi.replaceFirst(':shopId', shopId),
          queryParameters: {
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
