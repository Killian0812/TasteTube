import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/store/data/shop_analytics.dart';

class AnalyticRepository {
  final Dio http;

  AnalyticRepository({required this.http});

  Future<Either<ApiError, ShopAnalytics>> fetchAnalytics(String shopId) async {
    try {
      final response =
          await http.get(Api.analyticByShopApi.replaceFirst(":shopId", shopId));
      final analytics = ShopAnalytics.fromJson(response.data);
      return Right(analytics);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
