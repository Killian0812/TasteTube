import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/order/cart.dart';

class OrderRepository {
  final Dio http;

  OrderRepository({required this.http});

  Future<Either<ApiError, Cart>> getCart() async {
    try {
      final response = await http.get(Api.cartApi);
      final cart = Cart.fromJson(response.data['cart']);
      return Right(cart);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
