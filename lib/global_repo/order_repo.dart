import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/product/product.dart';

class OrderRepository {
  final Dio http;

  OrderRepository({required this.http});

  // Future<Either<ApiError, List<Product>>> searchSingleShopProducts(
  //     String shopId, String keyword) async {
  //   try {
  //     final response = await http.get(
  //         Api.singleShopSearchApi.replaceFirst(':shopId', shopId),
  //         queryParameters: {
  //           'keyword': keyword,
  //         });
  //     final List<dynamic> data = response.data;
  //     final products = data.map((json) => Product.fromJson(json)).toList();
  //     return Right(products);
  //   } on DioException catch (e) {
  //     return Left(ApiError.fromDioException(e));
  //   } catch (e) {
  //     return Left(ApiError(500, e.toString()));
  //   }
  // }
}
